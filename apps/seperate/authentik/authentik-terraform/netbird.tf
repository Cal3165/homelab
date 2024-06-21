data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_flow" "default-device-flow" {
  slug = "default-source-pre-authentication"
}

resource "authentik_brand" "authentik-default" {
  domain = "authentik-default"
  flow_device_code = data.authentik_flow.default-device-flow.id
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

resource "authentik_application" "netbird" {
  name              = "Netbird"
  slug              = replace(lower("Netbird"), "/w", "_")
  protocol_provider = authentik_provider_oauth2.netbird.id
}

resource "authentik_user" "netbird" {
  username = "Netbird"
  name     = "Netbird"
  type     = "service_account"
  path     = "goauthentik.io/service-accounts"
  groups = [data.authentik_group.akadmins.id]
}

resource "authentik_token" "netbird_password" {
  identifier  = "netbird_password"
  user        = authentik_user.netbird.id
  description = "Netbird Password"
  expiring = false
}

resource "authentik_policy_binding" "app-access" {
  target = authentik_application.netbird.uuid
  user = authentik_user.netbird.id
  order  = 0
}