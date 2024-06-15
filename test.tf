module "authentik" {
  source = "git::https://git.notusa.uk/ops/homelab.git//authentik-terraform"
  authentik_token = "pLvzbWrsBv409FtBZ7S73m4Giu9ddH8JQDSiHXOpBjg0705fP6HYEgTONgtC"
  grafana_redirect_uri = "https://grafana.notusa.uk/login/generic_oauth"
  grafana_client_id = ""
  argocd_client_id = ""
  argocd_redirect_uri = "https://argocd.notusa.uk/api/dex/callback"
  authentik_url = "https://authentik-server.authentik/"
}