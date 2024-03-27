provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "stephen-vpc"
}

# Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
}

# Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
}

# NAT Gateway using Cloud NAT for the private subnet
resource "google_compute_router" "router" {
  name    = "nat-router"
  network = google_compute_network.vpc_network.name
  region  = var.region
}

resource "google_compute_address" "google_compute_address" {
  name   = "adiyodi-assign2-nat-ip"
  region = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "adiyodi-assign2-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.google_compute_address.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Firewall to allow internal traffic within the VPC
resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.0.0/16"]
}

# Firewall to allow external traffic to application port
resource "google_compute_firewall" "firewall" {
  name    = "allow-5000"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Compute Engine instance within the private subnet
resource "google_compute_instance" "private_instance" {
  name         = "adiyodi-assign2-flask-app-instance"
  machine_type = "e2-medium"
  zone         = var.zones[0]
  tags         = ["flask-app"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.self_link
    // No access_config block as it's a private subnet
  }

  metadata = {
    gce-container-declaration = <<-EOT
spec:
  containers:
    - name: flask-app
      image: n    gcr.io/devops-414504/adiyodi-assignment2/flask_app:latest:latest
      env:
        - name: PORT
          value: "5000"
      ports:
        - containerPort: 5000
  restartPolicy: Always
EOT
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["cloud-platform"]
  }

  # Ensure the instance can start after being created or updated
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

# Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name = "adiyodi-assign2-lb-ip"
}

resource "google_compute_backend_service" "backend_service" {
  name                  = "backend-service"
  protocol              = "HTTP"
  timeout_sec           = 300
  port_name             = "http"
  enable_cdn            = false
  health_checks         = [google_compute_health_check.health_check.id]
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_health_check" "health_check" {
  name = "health-check"
  
  http_health_check {
    port               = 5000
    request_path       = "/"
    check_interval_sec = 5
    timeout_sec        = 5
  }
}


resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name                  = "forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = "80"
  global_address        = google_compute_global_address.lb_ip.self_link
  target                = google_compute_target_http_proxy.http_proxy.self_link
  load_balancing_scheme = "EXTERNAL"
}
