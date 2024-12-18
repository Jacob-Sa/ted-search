variable "account_id" {
  description = "The account id"
  type        = string
}

variable "insance_name" {
  description = "The name of the instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
}

variable "zone" {
  description = "The zone where the instance runs"
  type        = string
}

variable "instance_tags" {
  description = "Instance tags"
  type        = list(string)
}

variable "image" {
  description = "Image of the for the instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the network"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnetwork"
  type        = string
}

variable "service_account_scopes" {
  description = "service account scopes"
  type        = list(string)
}


variable "firewall_name" {
  description = "firewall name"
  type        = string
}

variable "source_ranges" {
  type        = list(string)
  description = "The source IP ranges allowed for this firewall rule"
}