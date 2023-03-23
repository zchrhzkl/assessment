# ================================================== VPC 01 ==================================================

# VPC 1
resource "google_compute_network" "vpc-01" {
  name = "${var.company}-app-${terraform.workspace}-vpc-1"
  description = "VPC for App ${terraform.workspace}"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}

# SUBNET 1
resource "google_compute_subnetwork" "vpc-01-subnet-1" {
  name          = "${var.company}-a-se1-app01-${terraform.workspace}-subnet-1"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.vpc-01.id
}

# FIREWALL RULE 1
resource "google_compute_firewall" "vpc-01-allow-ssh" {
  name    = "vpc-01-services-allow-ssh"
  network = google_compute_network.vpc-01.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# FIREWALL RULE 2
resource "google_compute_firewall" "vpc-01-allow-prometheus" {
  name    = "vpc-01-allow-prometheus"
  network = google_compute_network.vpc-01.id

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["10.0.0.0/16","10.1.0.0/16"]
}

# FIREWALL RULE 3
resource "google_compute_firewall" "vpc-01-allow-icmp" {
  name    = "vpc-01-allow-icmp"
  network = google_compute_network.vpc-01.id
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.20.10.0/24"]
}

# FIREWALL RULE 4
resource "google_compute_firewall" "vpc-01-allow-http" {
  name    = "vpc-01-allow-http"
  network = google_compute_network.vpc-01.id

  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }

  source_ranges = ["10.0.0.0/16","10.1.0.0/16","0.0.0.0/0"]
}

resource "google_compute_address" "nat_ip" {
  name    = "${var.company}-${terraform.workspace}-nat-ip"
}

resource "google_compute_router" "nat-router" {
  name    = "${var.company}-${terraform.workspace}-nat-router"
  network = google_compute_network.vpc-01.name
}

resource "google_compute_router_nat" "nat-gateway" {
  name                               = "${var.company}-nat-gateway"
  router                             = google_compute_router.nat-router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [ google_compute_address.nat_ip.self_link ]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  depends_on                         = [ google_compute_address.nat_ip ]
}

# show nat ip address
output "nat_ip_address" {
  value = google_compute_address.nat_ip.address
}

# ================================================== VPC 02 ==================================================

resource "google_compute_network" "vpc-02" {
  name = "${var.company}-mon-${terraform.workspace}-vpc-2"
  auto_create_subnetworks = false
  description = "VPC for Monitoring using Grafana"
}

# SUBNET 1
resource "google_compute_subnetwork" "vpc-02-subnet-1" {
  name          = "${var.company}-a-se1-mon-${terraform.workspace}-subnet-1"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.vpc-02.id
}

# FIREWALL RULE 1
resource "google_compute_firewall" "vpc-02-allow-ssh" {
  name    = "vpc-02-allow-ssh"
  network = google_compute_network.vpc-02.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# FIREWALL RULE 2
resource "google_compute_firewall" "vpc-02-allow-prometheus" {
  name    = "vpc-02-allow-prometheus"
  network = google_compute_network.vpc-02.id

  allow {
    protocol = "tcp"
    ports    = ["9090"]
  }

  source_ranges = ["10.0.0.0/16"]
}

# FIREWALL RULE 3
resource "google_compute_firewall" "vpc-02-allow-icmp" {
  name    = "vpc-02-allow-icmp"
  network = google_compute_network.vpc-02.id
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16","10.1.0.0/16"]
}

# =============================================== NETWORK PEER ===============================================

resource "google_compute_network_peering" "peering1" {
  name         = "${terraform.workspace}-net-peer-1"
  network      = google_compute_network.vpc-01.self_link
  peer_network = google_compute_network.vpc-02.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "${terraform.workspace}-net-peer-2"
  network      = google_compute_network.vpc-02.self_link
  peer_network = google_compute_network.vpc-01.self_link
}