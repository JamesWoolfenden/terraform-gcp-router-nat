resource "google_compute_network" "private" {
  name                            = "nat-private"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}
