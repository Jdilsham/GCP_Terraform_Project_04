locals {
  network    = var.network
  subnetwork = var.subnetwork
}

resource "google_container_cluster" "gke_cluster" {
  name     = "my-gke-cluster"
  location = var.zone

  deletion_protection = false

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

resource "google_container_node_pool" "primary_nodes" {
  name = "primary-node-pool"
  location = var.zone
    cluster  = google_container_cluster.gke_cluster.name

    node_count = 1

    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 20
      disk_type = "pd-standard"
      oauth_scopes = [ 
        "https://www.googleapis.com/auth/cloud-platform"
       ]

       labels = {
         environment = "dev"
       }

       tags = [ "gke-node" ]
    }

    autoscaling {
      min_node_count = 1
      max_node_count = 2
    }

    management {
      auto_repair = true
      auto_upgrade = true
    }
}

