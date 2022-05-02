terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

data "yandex_iam_service_account" "service" {
  name       = "service"
}

resource "yandex_kubernetes_cluster" "kube_cluster" {
  name        = "${var.name}"
  description = "Made with Terraform"

  network_id = "${var.network_id}"

  master {
    version = "1.21"
    zonal {
      zone      = "${var.zone}"
      subnet_id = "${var.subnet_id}"
    }

    public_ip = true

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "15:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = "${data.yandex_iam_service_account.service.id}"
  node_service_account_id = "${data.yandex_iam_service_account.service.id}"

  labels = {
    my_key       = "my_value"
    my_other_key = "my_other_value"
  }

  release_channel = "RAPID"
  network_policy_provider = "CALICO"
}

resource "yandex_kubernetes_node_group" "kube_nodes" {
  cluster_id  = "${yandex_kubernetes_cluster.kube_cluster.id}"
  name        = "${var.name}-nodes"
  description = "Made with Terraform"
  version     = "1.21"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = ["${var.subnet_id}"]
    }

    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.number_workers
    }
  }

  allocation_policy {
    location {
      zone = "${var.zone}"
    }
  }
}
