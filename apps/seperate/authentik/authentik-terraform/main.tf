#Providers
terraform {
  required_providers {

    authentik = {
      source = "goauthentik/authentik"
      version = "2024.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26.0"
    }

  }
  backend "kubernetes" {
    secret_suffix    = "state"
    namespace = "authentik"
  }
}


provider "authentik" {
  url   = local.authentik_url
  token = data.kubernetes_secret.terraform-config-secrets.data.authentik-token
  insecure = true
}

provider "kubernetes" {
}

locals {
  argocd_redirect_uri = "https://argocd.notusa.uk/api/dex/callback"
  grafana_redirect_uri = "https://grafana.notusa.uk/login/generic_oauth"
  authentik_url = "https://authentik-server/"
}

data "kubernetes_secret" "terraform-config-secrets" {
  metadata {
    name = "terraform-config-secrets"
    namespace = "authentik"
  }
}

data "authentik_certificate_key_pair" "generated" {
  name = "authentik Self-signed Certificate"
}

# Defualts
data "authentik_scope_mapping" "scope-email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_scope_mapping" "scope-profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_scope_mapping" "scope-openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

data "authentik_scope_mapping" "scope-offline-access" {
  name = "authentik default OAuth Mapping: OpenID 'offline_access'"
}

# Create a scope mapping
resource "authentik_scope_mapping" "gitea" {
  name       = "authentik gitea OAuth Mapping: OpenID 'gitea'"
  scope_name = "gitea"
  expression = <<EOF
gitea_claims = {}
if request.user.ak_groups.filter(name="gituser").exists():
    gitea_claims["gitea"]= "user"
if request.user.ak_groups.filter(name="gitadmin").exists():
    gitea_claims["gitea"]= "admin"
if request.user.ak_groups.filter(name="gitrestricted").exists():
    gitea_claims["gitea"]= "restricted"

return gitea_claims
EOF
}

# Homepage API Token
resource "authentik_token" "homepage-token" {
  identifier    = "homepage-token"
  user          = data.authentik_user.akadmin.id
  description   = "A Token For Homepage Intergration"
  intent        = "api"
  expiring      = false
  retrieve_key  = true
}

resource "kubernetes_secret" "authentik_setup_output" {
  metadata {
    name = "authentik-setup-output"
    namespace = "global-secrets"
  }
  data = {
    grafana_secret = module.grafana.provider_secret
    argocd_secret = module.argocd.provider_secret
    gitea_secret = module.gitea.provider_secret
    homepage_token = authentik_token.homepage-token.key
    netbird_password = authentik_token.netbird_password.key
  }
}

### Traefik ###
resource "authentik_provider_proxy" "traefik-provider" {
  name                  = "traefik-provider"
  mode                  = "forward_single"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  external_host         = "https://traefik.notusa.uk/"
}
resource "authentik_application" "traefik-application" {
  name              = "Traefik"
  slug              = "traefik-application"
  protocol_provider = authentik_provider_proxy.traefik-provider.id
}

resource "authentik_provider_proxy" "domain-proxy-provider" {
  name                  = "domain-proxy-provider"
  mode                  = "forward_domain"
  external_host = "https://auth.notusa.uk/"
  cookie_domain = "notusa.uk"
  access_token_validity = "hours=24"
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
}

resource "authentik_application" "application_domain_forward_auth" {
  name              = "Domain Proxy"
  slug              = "domain-proxy-application"
  protocol_provider = authentik_provider_proxy.domain-proxy-provider.id
  meta_launch_url   = "blank://blank"
}

resource "authentik_service_connection_kubernetes" "local" {
  name = "Local Kubernetes Cluster"
  local = true
}

resource "authentik_outpost" "proxy_outpost" {
  name = "Proxy Outpost"
  protocol_providers = [
  authentik_provider_proxy.domain-proxy-provider.id,
  authentik_provider_proxy.traefik-provider.id
  ]
  config = jsonencode({
    authentik_host = format("https://auth.notusa.uk")
    authentik_host_insecure = false
  })
  service_connection = authentik_service_connection_kubernetes.local.id
}