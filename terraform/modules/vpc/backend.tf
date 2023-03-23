terraform {
backend "gcs" {
    bucket  = "6b769ba7ce2afa11-bucket-tfstate"
    prefix  = "terraform/vpc/state"
  }
}