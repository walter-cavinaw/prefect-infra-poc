resource "google_kms_key_ring" "terraform-backend" {
  project  = var.project_id
  location = var.project_region
  name     = var.kms_key_ring_name
}

resource "google_kms_crypto_key" "terraform-backend" {
  name            = var.kms_key_name
  key_ring        = google_kms_key_ring.terraform-backend.id
  rotation_period = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [ google_kms_key_ring.terraform-backend ]
}

resource "google_kms_crypto_key_iam_binding" "terraform-backend" {
  crypto_key_id = google_kms_crypto_key.terraform-backend.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com",
  ]

  depends_on = [ google_kms_crypto_key.terraform-backend ]
}

resource "google_storage_bucket" "terraform-backend" {
  name                        = var.bucket_name
  location                    = var.project_region
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = true
  }
  encryption {
    default_kms_key_name = google_kms_crypto_key.terraform-backend.id
  }

  depends_on = [ google_kms_crypto_key.terraform-backend ]
}
