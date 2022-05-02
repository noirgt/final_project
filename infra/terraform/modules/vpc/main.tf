terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

resource "yandex_vpc_network" "vm-network" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "vm-subnet" {
  name           = var.subnet_name
  zone           = "ru-central1-a"
  network_id     = "${resource.yandex_vpc_network.vm-network.id}"
  v4_cidr_blocks = var.v4_cidr_blocks
}
