variable "gcp_project_id" {
  type = string
}

variable "gcp_project_region" {
  type = string
}

variable "gcp_registry_repo_name" {
  type = string
  description = "Name of the GCP artifact registry where flows Docker images are stored"
}

variable "gcp_cloud_run_worker_name" {
  type = string
  description = "Name of the GCP Cloud Run worker that polls prefect work pool for any scheduled jobs"
}

variable "prefect_work_pool_name" {
  type = string
}

variable "prefect_sa_name" {
  type = string
  description = "Name of service account that's used for the prefect worker"
}

variable "prefect_account_id" {
  type = string
}

variable "prefect_workspace_id" {
  type = string
}

variable "prefect_api_key" {
  type = string
}