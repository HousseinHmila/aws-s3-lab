module "lab-terminal" {
  source = "/mnt/efs/modules/terraform-module-lab-terminal"
  name            = "${var.instance_id}-terminal"
  subnet_id       = local.subnet_id
  vpc_id          = local.vpc_id
  ami_name        = local.ami_name
  configuration   = "dedicated"
  lab_instance_id = var.instance_id
  platform_top_level_domain = var.platform_top_level_domain
  platform_base_domain = var.platform_base_domain
  providers = {
    aws      = aws
    aws.main = aws.main
  }
}
