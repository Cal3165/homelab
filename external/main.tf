module "cloudflare" {
  source                = "./modules/cloudflare"
  cloudflare_account_id = var.cloudflare_account_id
  cloudflare_email      = var.cloudflare_email
  cloudflare_api_key    = var.cloudflare_api_key
}

module "ntfy" {
  source = "./modules/ntfy"
  auth   = var.ntfy
}

module "authentik_secrets" {
  source = "./modules/extra-secrets"
  data   = var.authentik_secrets
  namespace = "authentik"
  name = "authentik-secrets"
}

module "turn_password" {
  source = "./modules/extra-secrets"
  data   = var.turn_password
  name = "turn-password"
}

module "extra_secrets" {
  source = "./modules/extra-secrets"
  data   = var.extra_secrets
}