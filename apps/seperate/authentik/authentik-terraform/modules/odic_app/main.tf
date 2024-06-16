data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_oauth2" "provider" {
  name          = var.app_name
  
  client_id     = var.app_client_id

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  redirect_uris = var.app_redirect_uris

  property_mappings = var.app_property_mappings
}

resource "authentik_application" "app" {
  name              = var.app_name
  slug              = replace(lower(var.app_name), "/w", "_")
  protocol_provider = authentik_provider_oauth2.provider.id
}

resource "authentik_group" "app_groups" {
  for_each   = toset(var.app_groups)
  name = each.key
}

resource "authentik_group" "app_admin_group" {
  name         = var.app_admin_group
  users        = var.app_admin_users
  is_superuser = true
}