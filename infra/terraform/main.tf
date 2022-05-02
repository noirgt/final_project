terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
  backend "s3" {
    key    = "terraform-states/ya-infra.tfstate"
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "vpc" {
  count                    = var.subnet_id == false ? 1 : 0

  source                   = "./modules/vpc"
  network_name             = "crawler-app-network"
  subnet_name              = "${var.subnet_name}"
  v4_cidr_blocks           = ["${var.subnet_cidr}"]
}

locals {
  vms                      = {
    "gitlab"               : {"cpu": 4, "memory": 4, "ip_static": true},
    "runner"               : {"cpu": 2, "memory": 2, "ip_static": true},
    "harbor"               : {"cpu": 2, "memory": 2, "ip_static": true},
  }
}

module "vm" {
  for_each                 = var.vm_name == false ? local.vms : {
    "${var.vm_name}": {"cpu": "${var.vm_cpu}", "memory": "${var.vm_memory}", "ip_static": false}
  }

  source                   = "./modules/vm"
  vm_name                  = "vm-${each.key}"
  public_key_path          = var.public_key_path
  vm_disk_image            = var.vm_disk_image
  subnet_id                = var.subnet_id == false ? module.vpc[0].vm-subnet.id : var.subnet_id
  private_key_path         = var.private_key_path

  cpu                      = each.value["cpu"]
  memory                   = each.value["memory"]
}

module "ansible-gitlab" {
  for_each                 = toset(["install_gitlab.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.vpc,
    module.vm
  ]
}

module "ansible-harbor" {
  for_each                 = toset(["install_harbor.yml"])
  source                   = "./modules/ansiblecall"
  private_key_path         = var.private_key_path
  playbook                 = each.key
  depends_on               = [
    module.ansible-gitlab
  ]
}
