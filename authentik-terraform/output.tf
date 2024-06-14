# output "grafana_id" {
#   value = module.grafana.provider_id
# }

output "grafana_secret" {
  value = module.grafana.provider_secret
  sensitive = true
}

# output "argocd_id" {
#   value = module.argocd.provider_id
# }

output "argocd_secret" {
  value = module.argocd.provider_secret
  sensitive = true
}

output "homepage-token" {
  value = authentik_token.homepage-token.key
  sensitive = true
}