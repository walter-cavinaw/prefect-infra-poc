resource "google_iam_workload_identity_pool" "gh-oidc" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = var.pool_display_name
  description               = var.pool_description
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "gh-oidc" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.gh-oidc.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = var.provider_display_name
  description                        = var.provider_description
  attribute_condition                = var.attribute_condition
  attribute_mapping                  = var.attribute_mapping
  oidc {
    allowed_audiences = var.allowed_audiences
    issuer_uri        = var.issuer_uri
  }

  depends_on = [ google_iam_workload_identity_pool.gh-oidc ]
}

resource "google_service_account_iam_member" "gh-oidc" {
  for_each           = var.sa_mapping
  service_account_id = each.value.sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gh-oidc.name}/${each.value.attribute}"

  depends_on = [ google_iam_workload_identity_pool.gh-oidc, google_iam_workload_identity_pool_provider.gh-oidc ]
}
