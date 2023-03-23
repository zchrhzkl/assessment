resource "google_compute_global_forwarding_rule" "global_forwarding_rule" {
  name       = "fe-${terraform.workspace}-forwarding-rule"
  target     = google_compute_target_http_proxy.target_http_proxy.self_link
  port_range = "80"
}

resource "google_compute_target_http_proxy" "target_http_proxy" {
  name    = "fe-${terraform.workspace}-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_backend_service" "backend_service" {
  name                    = "fe-${terraform.workspace}-backend-svc"
  port_name               = "http"
  protocol                = "HTTP"
  load_balancing_scheme   = "EXTERNAL"
  health_checks           = ["${google_compute_health_check.healthcheck.self_link}"]

  backend {
    group                 = "${google_compute_instance_group_manager.web_private_group.instance_group}"
    balancing_mode        = "RATE"
    max_rate_per_instance = 100
  }
}

resource "google_compute_instance_group_manager" "web_private_group" {
  name                 = "fe-${terraform.workspace}-vm-group"
  base_instance_name   = "fe-${terraform.workspace}-react"
  version {
    instance_template  = "${google_compute_instance_template.fe_server.self_link}"
  }
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_health_check" "healthcheck" {
  name               = "fe-${terraform.workspace}-healthcheck"
  timeout_sec        = 1
  check_interval_sec = 1
  http_health_check {
    port = 80
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "fe-${terraform.workspace}-load-balancer"
  default_service = google_compute_backend_service.backend_service.self_link
}

resource "google_compute_autoscaler" "autoscaler" {
  name    = "fe-${terraform.workspace}-autoscaler"
  target  = "${google_compute_instance_group_manager.web_private_group.self_link}"

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

output "load-balancer-ip-address" {
  value = google_compute_global_forwarding_rule.global_forwarding_rule.ip_address
}