resource "google_compute_network" "vpc" {
  name                    = "${var.network_name}-${terraform.workspace}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "custom-subnet" {
  name          = "${var.subnet}-${terraform.workspace}"
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc.id
}

