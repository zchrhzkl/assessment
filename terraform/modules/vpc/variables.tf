variable "company" {
  type        = string
  description = "GCP Company Name"
}

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