
# Configure the AWS Provider
provider "aws" {
  region = "eu-north-1"
  assume_role {
    duration = "20m"
    role_arn = var.target_role_arn
  }
}

provider "aws" {
  alias  = "main"
  region = var.lab_aws_region
}