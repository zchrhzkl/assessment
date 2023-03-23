resource "google_compute_instance_template" "fe_server" {
  name                  = "${var.ce_name}-01-${terraform.workspace}-ce"
  description           = "This template is used to create web server instances running Apache"
  instance_description  = "Web Server running Apache"
  machine_type          = "n1-highcpu-2"
  tags                  = ["ssh","http","https"]
  can_ip_forward        = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image      = data.google_compute_image.rocky_9.id
    auto_delete       = true
    boot              = true
    resource_policies = [google_compute_resource_policy.daily_backup.id]
  }

  network_interface {
    network       = var.ce_network_name
    subnetwork    = var.ce_network_subnet
    access_config {
      # PREMIUM, FIXED_STANDARD or STANDARD
      network_tier = "PREMIUM"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata = {
    ssh-keys = "cloud-user:${file(var.GCP_FE_PUB_KEY)}"
    GOOGLE_APPLICATION_CREDENTIALS = "${file(var.GOOGLE_APPLICATION_CREDENTIALS)}"
    common-playbook = file("../../../ansible/roles/common/tasks/common-tasks.yml")
    docker-playbook = file("../../../ansible/roles/docker/tasks/docker.yml")
    docker-compose = file("../../../docker-compose.yml")
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash

    # Update Packages
    sudo dnf update -y

    # Installing Ops Agent for Monitoring
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
  EOF
}

resource "google_compute_resource_policy" "daily_backup" {
  name   = "every-day-3am"
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "03:00"
      }
    }
  }
}

data "google_compute_image" "rocky_9" {
  project  = var.rocky_project
  family = var.rocky_9_x86_64_sku
}