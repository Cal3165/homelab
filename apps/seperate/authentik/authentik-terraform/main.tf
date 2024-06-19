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
  }
}