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
