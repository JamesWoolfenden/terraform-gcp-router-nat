resource "google_compute_router" "main" {
  name        = var.name
  region      = var.region
  network     = var.network
  description = var.description

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
