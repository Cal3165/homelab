module "grafana" {
  source = "./modules/odic_app"
  app_name = "Grafana"
  app_client_id = var.grafana_client_id
  app_redirect_uris = [var.grafana_redirect_uri]
  app_property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-openid.id,
  ]
  app_admin_group = "Grafana Admins"
  app_admin_users = [data.authentik_user.akadmin.id, authentik_user.caleb.id]
  app_groups = ["Grafana Editors", "Grafana Viewers"]
}

module "argocd" {
  source = "./modules/odic_app"
  app_name = "ArgoCD"
  app_client_id = var.argocd_client_id
  app_redirect_uris = [
    var.argocd_redirect_uri,
    "http://localhost:8085/auth/callback"
  ]
  app_property_mappings = [
    data.authentik_scope_mapping.scope-email.id,
    data.authentik_scope_mapping.scope-profile.id,
    data.authentik_scope_mapping.scope-openid.id,
  ]
  app_admin_group = "ArgoCD Admins"
  app_admin_users = [data.authentik_user.akadmin.id, authentik_user.caleb.id]
  app_groups = ["ArgoCD Viewers"]
}