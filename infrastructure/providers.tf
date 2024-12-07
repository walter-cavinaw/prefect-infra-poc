provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_project_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_project_region
}

provider "prefect" {
  api_key      = var.prefect_api_key
  account_id   = var.prefect_account_id
  workspace_id = var.prefect_workspace_id
  endpoint     = "https://api.prefect.cloud"
}
