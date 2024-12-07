terraform {
  backend "gcs" {
    bucket = "prefect-poc-terraform-backend"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
    prefect = {
      source = "prefecthq/prefect"
    }
  }
}

resource "google_service_account" "cicd-sa" {
  project      = var.gcp_project_id
  account_id   = "cicdprocess"
  display_name = "cicdprocess"
  description  = "CICD Processes including Github Actions"
}

resource "google_project_iam_member" "cicd-sa" {
  for_each = toset([
    "roles/cloudkms.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/storage.admin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/artifactregistry.reader"
  ])
  role    = each.value
  project = var.gcp_project_id
  member  = "serviceAccount:${google_service_account.cicd-sa.email}"
}

module "gh-oidc" {
  source = "./modules/gh-oidc"

  project_id            = var.gcp_project_id
  pool_id               = "cicd-pool"
  pool_display_name     = "cicd-pool"
  pool_description      = "Identities for CICD Tools"
  provider_id           = "gh-provider"
  provider_display_name = "gh-provider"
  sa_mapping = {
    (google_service_account.cicd-sa.account_id) = {
      sa_name   = google_service_account.cicd-sa.name
      attribute = "attribute.repository/${var.gh_repo}"
    }
  }
}

module "terraform-backend" {
  source = "./modules/terraform-backend"

  project_id        = var.gcp_project_id
  project_number    = var.gcp_project_number
  project_region    = var.gcp_project_region
  bucket_name       = "prefect-poc-terraform-backend"
  kms_key_ring_name = "gcs"
  kms_key_name      = "terraform-backend"
  rotation_period   = "86400s"
}

module "prefect" {
  source = "./modules/prefect"

  gcp_project_id = var.gcp_project_id
  gcp_project_region = var.gcp_project_region
  gcp_registry_repo_name = "docker"
  gcp_cloud_run_worker_name = "prefect-worker"
  
  prefect_account_id =  var.prefect_account_id
  prefect_workspace_id = var.prefect_workspace_id
  prefect_api_key = var.prefect_api_key
  prefect_work_pool_name = "cloud-run-pool"
  prefect_sa_name = "prefect-service-account"
}