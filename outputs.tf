output "router_id" {
  value       = google_compute_router.main.id
  description = "ID of the Cloud Router"
}

output "router_name" {
  value       = google_compute_router.main.name
  description = "Name of the Cloud Router"
}

output "router_self_link" {
  value       = google_compute_router.main.self_link
  description = "Self link of the Cloud Router"
}

output "nat_id" {
  value       = google_compute_router_nat.main.id
  description = "ID of the Cloud NAT gateway"
}

output "nat_name" {
  value       = google_compute_router_nat.main.name
  description = "Name of the Cloud NAT gateway"
}

output "nat_ip_addresses" {
  value       = { for k, a in google_compute_address.nat : k => a.address }
  description = "Static external egress IP addresses keyed by suffix (empty when nat_ip_allocate_option is AUTO_ONLY)"
}
