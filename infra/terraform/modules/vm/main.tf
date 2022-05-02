terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

resource "yandex_compute_instance" "vm" {
  name = var.vm_name
  allow_stopping_for_update = true

  labels = {
    tags = var.vm_name
  }
  resources {
    cores  = var.cpu
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = var.vm_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat = true
  }

  metadata = {
     ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
}

resource "null_resource" "install_python" {
    connection {
    type        = "ssh"
    host        = yandex_compute_instance.vm.network_interface.0.nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
    }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /var/lib/dpkg/lock* && sudo apt -y install python"
    ]
  }
  depends_on = [
    yandex_compute_instance.vm
  ]
}
