# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "router_nat" {
  source  = "../../"
  name    = "example-router"
  region  = "europe-west2"
  network = google_compute_network.private.id

  subnetworks = [
    {
      name                    = google_compute_subnetwork.nodes.self_link
      source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
    }
  ]
}
