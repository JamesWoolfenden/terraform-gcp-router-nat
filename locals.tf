locals {
  nat_name = coalesce(var.nat_name, "${var.name}-nat")

  # Self links of the static addresses; null under AUTO_ONLY so Google allocates the IPs.
  nat_ips = var.nat_ip_allocate_option == "MANUAL_ONLY" ? [for a in google_compute_address.nat : a.self_link] : null
}
