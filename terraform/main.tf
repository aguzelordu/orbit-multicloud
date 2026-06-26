module "aws_infra" {
  source     = "aws_infra"
  aws_region = var.aws_region
}

module "gcp_infra" {
  source         = "gcp_infra"
  gcp_project_id = var.gcp_project_id
  gcp_region     = var.gcp_region
  gcp_zone       = var.gcp_zone
}