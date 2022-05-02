variable "cloud_id" {
  description = "Cloud"
}
variable "folder_id" {
  description = "Folder"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}

variable "region" {
  description = "Region"
  # Значение по умолчанию
  default = "ru-central1"
}

variable "public_key_path" {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  # Описание переменной
  description = "Path to the private key used for provisioners"
}

variable "image_id" {
  description = "Disk image"
}

variable "subnet_id" {
  description = "Subnet"
  default     = false
}

variable "network_id" {
  description = "Network"
}

variable "service_account_key_file" {
  description = "key .json"
}

variable "vm_disk_image" {
  description = "Disk image for reddit vm"
  default     = "reddit-vm-base"
}

variable "vm_name" {
  description = "Name of VM"
  default     = false
}

variable "vm_cpu" {
  description = "CPU of VM"
  default     = 2
}

variable "vm_memory" {
  description = "Memory of VM"
  default     = 2
}

variable "subnet_name" {
  description = "Name of subnet"
  default     = "default-subnet"
}

variable "subnet_cidr" {
  description = "CIDR of subnet"
  default     = "192.168.8.0/24"
}
