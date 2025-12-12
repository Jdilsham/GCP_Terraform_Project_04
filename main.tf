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
  name     = "primary-node-pool"
  location = var.zone
  cluster  = google_container_cluster.gke_cluster.name

  node_count = 1

  node_config {
    machine_type    = "e2-medium"
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    service_account = google_service_account.gke_nodes.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = "dev"
    }

    tags = ["gke-node"]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}

resource "google_service_account" "gke_nodes" {
  account_id   = "gke-node-sa"
  display_name = "GKE Node Service Account"
}

resource "google_project_iam_member" "gke_nodes_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_node_service_agent" {
  project = var.project_id
  role    = "roles/container.nodeServiceAgent"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

