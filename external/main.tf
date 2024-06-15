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

module "terraform_api_key" {
  source = "./modules/extra-secrets"
  data   = var.terraform_api_key
  namespace = "terraform-system"
  name = "terraformrc"
}

module "extra_secrets" {
  source = "./modules/extra-secrets"
  data   = var.extra_secrets
}

module "authentik_terraform_config_map" {
  source = "./modules/configmap"
  data = {
    "main.tf" = "${file("${path.root}/../authentik-terraform/main.tf")}"
    "odic_apps.tf" = "${file("${path.root}/../authentik-terraform/odic_apps.tf")}"
    "users.tf" = "${file("${path.root}/../authentik-terraform/users.tf")}"
    "odic_app_main.tf" = "${file("${path.root}/../authentik-terraform/modules/odic_app/main.tf")}"
    "odic_app_outputs.tf" = "${file("${path.root}/../authentik-terraform/modules/odic_app/outputs.tf")}"
    "odic_app_variables.tf" = "${file("${path.root}/../authentik-terraform/modules/odic_app/variables.tf")}"
    "odic_app_versions.tf" = "${file("${path.root}/../authentik-terraform/modules/odic_app/versions.tf")}"
  }
  name = "authentik-terraform"
  namespace = "authentik"
}