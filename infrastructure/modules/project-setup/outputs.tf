output "cicd_sa_id" {
  value = google_service_account.cicd-sa.account_id
}

output "cicd_sa_name" {
  value = google_service_account.cicd-sa.name
}

output "prefect_sa_email" {
  value = google_service_account.prefect-sa.email
}