data "google_service_account" "default" {
  account_id = var.account_id
}

resource "google_compute_instance" "instance" {
  name         = "${var.insance_name}-${terraform.workspace}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.instance_tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id

    access_config {
      // Ephemeral public IP
    }
  }


  service_account {
    email  = data.google_service_account.default.email
    scopes = var.service_account_scopes
  }
}


# # Firewall rule to allow HTTP traffic to the private subnet
# resource "google_compute_firewall" "allow-http" {
#   name    = "allow-http"
#   network =var.vpc_id

#   allow {
#     protocol = "tcp"
#     ports    = ["80"]
#   }

#   source_ranges = ["0.0.0.0/0"]
# }

# Managed instance group for the private instance
resource "google_compute_instance_group" "instance_group" {
  name        = "private-instance-group"
  zone        = "us-central1-a"
  instances   = [google_compute_instance.instance.self_link]
  named_port {
    name = "http"
    port = 80
  }
}

# Health check for the load balancer
resource "google_compute_health_check" "http_health_check" {
  name = "http-health-check"

  http_health_check {
    port = 80
  }
}

# Backend service for the load balancer
resource "google_compute_backend_service" "backend_service" {
  name                  = "http-backend-service"
  health_checks         = [google_compute_health_check.http_health_check.self_link]
  backend {
    group = google_compute_instance_group.instance_group.self_link
  }
}

# URL map for the load balancer
resource "google_compute_url_map" "url_map" {
  name            = "http-url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

# HTTP proxy for the load balancer
resource "google_compute_target_http_proxy" "http_proxy" {
  name   = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

# Reserve a global IP address for the load balancer
resource "google_compute_global_address" "lb_ip" {
  name = "http-lb-ip"
}

# Forwarding rule for the load balancer
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name       = "http-forwarding-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.self_link
}


resource "google_compute_firewall" "allow_http_inbound" {
  name    = "${var.firewall_name}-${terraform.workspace}"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }

  source_ranges = var.source_ranges
  target_tags   = var.instance_tags
}

resource "terraform_data" "deploy_app" {

  triggers_replace = [
    google_compute_instance.instance.id,
    md5("../docker-compose.yaml"),
    md5("../nginx.conf"),
    md5("../app/src/main/resources/static")
  ]
  provisioner "file" {
    source      = "../docker-compose.yaml"
    destination = "/home/ubuntu/docker-compose.yaml"

    connection {
      type        = "ssh"
      host        = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "../nginx.conf"
    destination = "/home/ubuntu/nginx.conf"

    connection {
      type        = "ssh"
      host        = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "../app/src/main/resources/static"
    destination = "/home/ubuntu/static"

    connection {
      type        = "ssh"
      host        = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "./startup-script.sh"
    destination = "/home/ubuntu/startup-script.sh"

    connection {
      type        = "ssh"
      host        = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/startup-script.sh",
      "sudo /home/ubuntu/startup-script.sh"
    ]

    connection {
      type        = "ssh"
      host        = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
    }
  }

}
