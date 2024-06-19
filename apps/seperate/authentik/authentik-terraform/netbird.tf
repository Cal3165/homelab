data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}


resource "authentik_provider_oauth2" "netbird" {
  name          = "Netbird"
  
  client_id     = data.kubernetes_secret.terraform-config-secrets.data.netbird-client-id

  authorization_flow  = data.authentik_flow.default-provider-authorization-implicit-consent.id

  redirect_uris = [
    "https://vpn.notusa.uk", 
    "https://vpn.notusa.uk.*", 
    "http://localhost:53000"
  ]

  signing_key =  data.authentik_certificate_key_pair.generated.id
  client_type = "public"
  access_code_validity = "minutes=10"
  sub_mode = "user_id"
  property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-openid.id,
    data.authentik_scope_mapping.scope-offline-access.id,
  ]
}

resource "authentik_application" "app" {
  name              = "Netbird"
  slug              = replace(lower("Netbird"), "/w", "_")
  protocol_provider = authentik_provider_oauth2.netbird.id
}

resource "authentik_user" "netbird" {
  username = "Netbird"
  name     = "Netbird"
  type     = "service_account"
  path     = "goauthentik.io/service-accounts"
  password = data.kubernetes_secret.terraform-config-secrets.data.netbird-token
  groups = data.authentik_group.akadmins.id
  attributes = {
    "goauthentik.io/user/token-expires": false
  }
}