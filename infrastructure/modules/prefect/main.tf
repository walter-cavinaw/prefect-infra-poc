terraform {
  required_providers {
    prefect = {
      source = "prefecthq/prefect"
    }
  }
}

resource "prefect_work_pool" "cloud-run-pool" {
  name              = var.prefect_work_pool_name
  type              = "cloud-run"
  account_id        = var.prefect_account_id
  workspace_id      = var.prefect_workspace_id
  paused            = false
  base_job_template = file("modules/prefect/resources/base-job-template.json")
}

resource "google_cloud_run_service" "prefect_worker" {
  name     = var.gcp_cloud_run_worker_name
  location = var.gcp_project_region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"  = 1
        "run.googleapis.com/cpu-throttling" = false
      }
    }
    spec {
      service_account_name = var.prefect_sa_email
      containers {
        image = "prefecthq/prefect:3-latest"
        args = [
          "prefect",
          "worker",
          "start",
          "--install-policy",
          "always",
          "--with-healthcheck",
          "-p",
          prefect_work_pool.cloud-run-pool.name,
          "-t",
          "cloud-run"
        ]
        env {
          name  = "PREFECT_API_URL"
          value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}"
        }
        env {
          name  = "PREFECT_API_KEY"
          value = var.prefect_api_key
        }
      }
      container_concurrency = 1
    }
  }
}

resource "google_artifact_registry_repository" "docker" {
  provider      = google-beta
  location      = var.gcp_project_region
  repository_id = var.gcp_registry_repo_name
  description   = "Docker repository for prefect flows"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-most-recent-10"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-untagged-older-than-30d"
    action = "DELETE"
    condition {
      older_than = "25920000s" # 30 days
      tag_state  = "UNTAGGED"
    }
  }
}
