resource "google_compute_network" "vpc" {
  name                    = "${var.network_name}-${terraform.workspace}"
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  private_ip_google_access = true # Enables private IP access to Google APIs
}


# Create a Cloud Router (required for Cloud NAT)
resource "google_compute_router" "cloud_router" {
  name    = "example-router"
  network = google_compute_network.vpc.name
  region  = var.region
}

# Create a Cloud NAT
resource "google_compute_router_nat" "cloud_nat" {
  name                               = "example-nat"
  router                             = google_compute_router.cloud_router.name
  region                             = google_compute_router.cloud_router.region
  nat_ip_allocate_option             = "AUTO_ONLY" # Automatically assign external IPs
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  # Optional: Log configuration
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}