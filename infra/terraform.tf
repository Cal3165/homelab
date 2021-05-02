terraform {
  # TODO (feature) Generate endpoint automatically (terragrunt for variable)
  backend "etcdv3" {
    endpoints = ["192.168.1.25:2379"]
    lock      = true
  }

  # TODO Better Terraform provider inheritance
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.5.0"
    }

    rke = {
      source  = "rancher/rke"
      version = "1.1.7"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.1.1"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name     = "homelab"
    scheme   = "https"
    address  = var.lxd_address
    password = var.lxd_password
    default  = true
  }
}

provider "rke" {
  debug = true
}
