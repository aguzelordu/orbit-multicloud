output "vm_private_ip" {
  value = google_compute_instance.recommendation_engine.network_interface[0].network_ip
}