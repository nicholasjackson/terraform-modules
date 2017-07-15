resource "google_container_cluster" "primary" {
  name               = "${var.namespace}-k8s-cluster"
  zone               = "${var.region}-b"
  initial_node_count = "${var.k8s_instances}"

  network = "${google_compute_network.default.self_link}"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_container_node_pool" "np" {
  name               = "${var.namespace}-k8s-nodepool"
  zone               = "${var.region}-b"
  cluster            = "${google_container_cluster.primary.name}"
  initial_node_count = "${var.k8s_nodes}"
}
