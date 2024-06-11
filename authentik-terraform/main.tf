#Providers
terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.2.0"
    }
  }
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
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



