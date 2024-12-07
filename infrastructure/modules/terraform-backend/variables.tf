variable "bucket_name" {
  type        = string
  description = "Name of the GCS bucket where terraform state file is stored"
}

variable "kms_key_name" {
  type        = string
  description = "Name of the KMS key used to encrypt GCS bucket"
}

variable "kms_key_ring_name" {
  type        = string
  description = "Name of KMS key ring where KMS key is stored"
}

variable "rotation_period" {
  type        = string
  description = "Every time this period passes, generate a new CryptoKeyVersion and set it as the primary [More info] (https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key#rotation_period-1)"
}

variable "project_region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "project_number" {
  type = number
}
