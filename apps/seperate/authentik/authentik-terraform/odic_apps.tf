module "grafana" {
  source = "./modules/odic_app"
  app_name = "Grafana"
  app_client_id = data.kubernetes_secret.terraform-config-secrets.data.grafana-client-id
  app_redirect_uris = [local.grafana_redirect_uri]
  app_property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.openid.id,
  ]
  app_admin_group = "Grafana Admins"
  app_admin_users = [data.authentik_user.akadmin.id, authentik_user.caleb.id]
  app_groups = ["Grafana Editors", "Grafana Viewers"]
}

module "argocd" {
  source = "./modules/odic_app"
  app_name = "ArgoCD"
  app_client_id = data.kubernetes_secret.terraform-config-secrets.data.argocd-client-id
  app_redirect_uris = [
    local.argocd_redirect_uri,
    "http://localhost:8085/auth/callback"
  ]
  app_property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.openid.id,
  ]
  app_admin_group = "ArgoCD Admins"
  app_admin_users = [data.authentik_user.akadmin.id, authentik_user.caleb.id]
  app_groups = ["ArgoCD Viewers"]
}

module "gitea" {
  source = "./modules/odic_app"
  app_name = "Gitea"
  app_client_id = data.kubernetes_secret.terraform-config-secrets.data.gitea-client-id
  app_redirect_uris = ["https://git.notusa.uk/user/oauth2/authentik/callback"]
  app_property_mappings = [
    data.authentik_property_mapping_provider_scope.email.id,
    data.authentik_property_mapping_provider_scope.profile.id,
    data.authentik_property_mapping_provider_scope.openid.id,
    authentik_property_mapping_provider_scope.gitea.id,
  ]
  app_admin_group = "gitadmin"
  app_admin_users = [data.authentik_user.akadmin.id, authentik_user.caleb.id]
  app_groups = ["gituser","gitrestricted"]
}