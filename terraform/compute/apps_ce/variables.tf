## Define GCP Auth
variable "GOOGLE_APPLICATION_CREDENTIALS" {
  type        = string
  description = "GCP Auth Key"
}

## Define GCP Project Name
variable "gcp_project" {
  type        = string
  description = "GCP Project Name"
}

## Define GCP Region
variable "gcp_region" {
  type        = string
  description = "GCP Region Name"
}

## Define GCP Zone
variable "gcp_zone" {
  type        = string
  description = "GCP Zone Name"
}

# GCP Compute Engine Variables

## Compute Engine Instance Name
variable "ce_name" {
  type        = string
  description = "Compute Engine Instance Name"
  # default     = "csshield-demo-vm"
}

## Compute Engine Instance Network Name
variable "ce_network_name" {
  type        = string
  description = "Compute Engine Instance Network Name"
}

## Compute Engine Instance Network Subnet
variable "ce_network_subnet" {
  type        = string
  description = "Compute Engine Instance Network Subnet"
}

variable "GCP_FE_PUB_KEY" {
  type        = string
  description = "Compute Engine SSH Public Key"
}

variable "IMAGE_TAG" {
  type        = string
  description = "Docker Image Tag for Running Ansible Playbook"
}

## Compute Engine Instance SSH Key
# variable "ssh_key" {
#   type        = string
#   description = "Compute Engine Instance SSH Key"
# }