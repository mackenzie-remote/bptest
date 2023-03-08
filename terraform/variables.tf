locals {
  region = "us-east-1"
  name   = "bptest"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/mackenzie-remote/bptest"
  }
}
variable "bptest_repo" {
  default     = "533740943112.dkr.ecr.us-east-1.amazonaws.com/bptest"
  description = "bptest image path (excluding tag)"
}
variable "bptest_tag" {
  default     = "latest"
  description = "bptest image tag"
}
variable "bucket_name" {
  default     = "terraform-bptest"
  description = "Passed to app --bucket-name parameter"
}