module "network" {
  source        = "./modules/network"
  subnet        = var.subnet
  region        = var.region
  network_name  = var.network_name
  ip_cidr_range = var.ip_cidr_range

}

module "compute" {
  source     = "./modules/compute"
  depends_on = [module.network]

  account_id             = var.account_id
  insance_name           = var.insance_name
  instance_tags          = var.instance_tags
  vpc_id                 = module.network.vpc_id
  subnet_id              = module.network.subnet_id
  image                  = var.image
  machine_type           = var.machine_type
  service_account_scopes = var.service_account_scopes
  zone                   = var.zone
  firewall_name          = var.firewall_name
  source_ranges          = var.source_ranges
}

