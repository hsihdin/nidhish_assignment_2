project_id              = "adiyodi_assignment2"
region                  = "us-central1"
vpc_name                = "adiyodi_assignment2-vpc"
public_subnet_name      = "public-subnet"
public_subnet_cidr      = "10.0.1.0/24"
private_subnet_name     = "private-subnet"
private_subnet_cidr     = "10.0.2.0/24"
instance_name           = "adiyodi_assignment2-instance"
instance_machine_type   = "e2-standard-2"
instance_zone           = "us-central1-a"
instance_image          = "debian-cloud/debian-10"
instance_startup_script = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y docker.io
  sudo docker run -d -p 80:80 your-container-image
EOF
firewall_name           = "allow-http"
firewall_port           = "80"
