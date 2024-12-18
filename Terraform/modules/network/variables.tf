variable "network_name" {
  type = string
  description = "The name of the network"
}

variable "subnet" {
  type = string
  description= "The name of the subnet"
}


variable "ip_cidr_range" {
  type = string
  description= "IP cidr range for the subnet"
}


variable "region" {
  type = string
  description = "region"
}