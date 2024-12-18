terraform {

  backend "gcs" {
    bucket = "ted-search"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.10.0"
    }
  }
}

provider "google" {
  project = "rapid-digit-439413-d7"
}