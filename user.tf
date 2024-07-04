module "user-sts" {
  source                   = "/mnt/efs/modules/terraform-module-lab-user"
  has_additional_policy    = false
  allowed_managed_policies = local.allowed_managed_policies
  user_id                  = local.user_id
}

locals {
  allowed_managed_policies = ["AmazonS3FullAccess"]
}
