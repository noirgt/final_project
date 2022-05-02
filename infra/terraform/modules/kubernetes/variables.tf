variable "name" {
  description = "Name of Kubernetes cluster"
}

variable "zone" {
  description = "Zone of Kubernetes cluster"
  default = "ru-central1-a"
}

variable "network_id" {
  description = "Network of Kubernetes cluster"
}

variable "subnet_id" {
  description = "Subnet of Kubernetes cluster"
}

variable "number_workers" {
  description = "Number of Kubernetes workers"
}