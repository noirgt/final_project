variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  # Описание переменной
  description = "Path to the private key used for provisioners"
}

variable "vm_disk_image" {
  description = "Disk image for reddit vm"
  default = "reddit-app-base"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "ip_static" {
  description = "Static IP for VM. True or false"
  default = false
}

variable "vm_name" {
  description = "Name of new VM"
}

variable "cpu" {
  description = "Number of CPU cores"
}

variable "memory" {
  description = "Value of memory"
}
