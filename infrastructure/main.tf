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

module "project-setup" {
  source = "./modules/project-setup"

  project_id = var.gcp_project_id
}

module "terraform-backend" {
  source = "./modules/terraform-backend"

  project_id        = var.gcp_project_id
  project_number    = var.gcp_project_number
  project_region    = var.gcp_project_region
  bucket_name       = var.terraform_backend_bucket_name
  kms_key_ring_name = "gcs"
  kms_key_name      = "terraform-backend"
  rotation_period   = "86400s"

  depends_on = [ module.project-setup ]
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
    (module.project-setup.cicd_sa_id) = {
      sa_name   = module.project-setup.cicd_sa_name
      attribute = "attribute.repository/${var.gh_repo}"
    }
  }

  depends_on = [ module.project-setup ]
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
  prefect_sa_email = module.project-setup.prefect_sa_email

  depends_on = [ module.project-setup ]
}