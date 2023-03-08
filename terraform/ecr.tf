resource "aws_ecr_repository" "bptest" {
  name                 = "bptest"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
