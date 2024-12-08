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
    "roles/artifactregistry.admin",
    "roles/run.admin"
  ])
  role    = each.value
  project = var.gcp_project_id
  member  = "serviceAccount:${google_service_account.cicd-sa.email}"
}

resource "google_service_account" "prefect-sa" {
  project      = var.gcp_project_id
  account_id   = "prefect-service-account"
  display_name = "prefect-service-account"
  description  = "Service account to use for the prefect worker"
}

resource "google_project_iam_member" "prefect-sa" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/run.admin"
  ])
  role    = each.value
  project = var.gcp_project_id
  member  = "serviceAccount:${google_service_account.prefect-sa.email}"
}