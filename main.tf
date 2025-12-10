locals {
  network    = var.network
  subnetwork = var.subnetwork
}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster"
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = local.network
  subnetwork = local.subnetwork

  ip_allocation_policy {}

  node_config {
    disk_size_gb = 20
    disk_type    = "pd-standard"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  release_channel {
    channel = "REGULAR"
  }


}