resource "google_compute_firewall" "deny_ingress" {
  name      = "nat-private-deny-ingress"
  network   = google_compute_network.private.id
  direction = "INGRESS"
  priority  = 65534

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
