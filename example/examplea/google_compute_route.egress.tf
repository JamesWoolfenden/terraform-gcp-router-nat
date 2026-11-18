# Explicit replacement for the deleted default route: Cloud NAT needs a path to the
# default internet gateway for the NATed subnet.
resource "google_compute_route" "egress" {
  name             = "nat-private-egress"
  network          = google_compute_network.private.id
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}
