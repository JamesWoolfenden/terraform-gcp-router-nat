resource "google_compute_router_nat" "main" {
  name   = local.nat_name
  router = google_compute_router.main.name
  region = var.region

  nat_ip_allocate_option = var.nat_ip_allocate_option
  nat_ips                = local.nat_ips

  # Only the subnetworks listed in var.subnetworks are NATed — never every subnet in the VPC.
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = var.subnetworks
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }

  # Endpoint-independent mapping lets any external host reach a VM's mapped port once it has
  # made an outbound connection; keep it off.
  enable_endpoint_independent_mapping = false

  min_ports_per_vm                 = var.min_ports_per_vm
  udp_idle_timeout_sec             = var.idle_timeouts.udp
  icmp_idle_timeout_sec            = var.idle_timeouts.icmp
  tcp_established_idle_timeout_sec = var.idle_timeouts.tcp_established
  tcp_transitory_idle_timeout_sec  = var.idle_timeouts.tcp_transitory
  tcp_time_wait_timeout_sec        = var.idle_timeouts.tcp_time_wait

  log_config {
    enable = true
    filter = var.log_filter
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
