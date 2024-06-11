output "grafana_id" {
  value = grafana.provider_id
}

output "grafana_secret" {
  value = grafana.provider_secret
  sensitive = true
}

output "argocd_id" {
  value = argocd.provider_id
}

output "argocd_secret" {
  value = argocd.provider_secret
  sensitive = true
}

output "homepage-token" {
  value = authentik_token.homepage-token.key
  sensitive = true
}