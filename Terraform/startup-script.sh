#!/bin/bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Start Docker Compose
cd /home/ubuntu
gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
sudo docker-compose up -d