resource "google_compute_network" "default" {
  name                    = "${var.namespace}-k8s"
  auto_create_subnetworks = "true"
}
