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
    config_path      = "~/.kube/config"
  }
}


provider "authentik" {
  url   = local.authentik_url
  token = data.kubernetes_secret.terraform-config-secrets.data.authentik-token
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

locals {
  argocd_redirect_uri = "https://argocd.notusa.uk/api/dex/callback"
  grafana_redirect_uri = "https://grafana.notusa.uk/login/generic_oauth"
  authentik_url = "https://auth.notusa.uk/"
}

data "kubernetes_secret" "terraform-config-secrets" {
  metadata {
    name = "terraform-config-secrets"
    namespace = "authentik"
  }
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
    homepage_token = authentik_token.homepage-token.key
  }
}