variable "project_id" {
  description = "The ID of the Google Cloud project"
  type        = string
}

variable "region" {
  description = "The region in which to deploy the resources"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR range for the public subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "The name of the private subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR range for the private subnet"
  type        = string
}

variable "instance_name" {
  description = "The name of the Compute Engine instance"
  type        = string
}

variable "instance_machine_type" {
  description = "The machine type for the Compute Engine instance"
  type        = string
}

variable "instance_zone" {
  description = "The zone in which to deploy the Compute Engine instance"
  type        = string
}

variable "instance_image" {
  description = "The image for the Compute Engine instance"
  type        = string
}

variable "instance_startup_script" {
  description = "The startup script for the Compute Engine instance"
  type        = string
}

variable "firewall_name" {
  description = "The name of the firewall rule"
  type        = string
}

variable "firewall_port" {
  description = "The port for the firewall rule"
  type        = string
}
variable "zones" {
  description = "A list of zones where the instance will be deployed"
  type        = list(string)
}
