resource "google_service_account" "cicd-sa" {
  project      = var.project_id
  account_id   = "cicdprocess"
  display_name = "cicdprocess"
  description  = "CICD Processes including Github Actions"

  depends_on = [
    google_project_service.artifactregistry, 
    google_project_service.cloudkms, 
    google_project_service.cloudresourcemanager, 
    google_project_service.containerregistry, 
    google_project_service.iam, 
    google_project_service.iamcredentials, 
    google_project_service.pubsub, 
    google_project_service.run, 
    google_project_service.secretmanager
  ]
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
  project = var.project_id
  member  = "serviceAccount:${google_service_account.cicd-sa.email}"

  depends_on = [google_service_account.cicd-sa]
}

resource "google_service_account" "prefect-sa" {
  project      = var.project_id
  account_id   = "prefect-service-account"
  display_name = "prefect-service-account"
  description  = "Service account to use for the prefect worker"

  depends_on = [
    google_project_service.artifactregistry, 
    google_project_service.cloudkms, 
    google_project_service.cloudresourcemanager, 
    google_project_service.containerregistry, 
    google_project_service.iam, 
    google_project_service.iamcredentials, 
    google_project_service.pubsub, 
    google_project_service.run, 
    google_project_service.secretmanager
  ]
}

resource "google_project_iam_member" "prefect-sa" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/run.admin"
  ])
  role    = each.value
  project = var.project_id
  member  = "serviceAccount:${google_service_account.prefect-sa.email}"

  depends_on = [google_service_account.prefect-sa]
}
