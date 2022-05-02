terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.74.0"
    }
  }
}

resource "null_resource" "ansible_deploy" {
  provisioner "local-exec" {
      command = "cd $ansible_path && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i $invetory $playbook"
      environment = {
          ansible_path   = "../ansible"
          invetory       = "inventory.py"
          playbook       = "playbooks/${var.playbook}"
      }
    }
}
