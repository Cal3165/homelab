output "provider_secret" {
  value = authentik_provider_oauth2.provider.client_secret
}
output "provider_id" {
  value = var.app_client_id
}