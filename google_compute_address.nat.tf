resource "google_compute_address" "nat" {
  for_each = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.nat_ip_suffixes : toset([])

  name         = "${var.name}-nat-${each.key}"
  region       = var.region
  description  = "Static egress IP ${each.key} for Cloud NAT ${local.nat_name}"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  labels       = var.labels

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  # NAT egress IPs are typically allowlisted by third parties; losing one is an outage.
  lifecycle {
    prevent_destroy = true
  }
}
