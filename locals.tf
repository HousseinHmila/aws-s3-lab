locals {
  name               = "${local.name_prefix}-vpc"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "172.10.0.0/16"
  subnet_id          = module.vpc.public_subnets[0]
  private_subnet_id  = module.vpc.private_subnets[0]
  region             = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.current.account_id
  name_prefix        = substr(var.instance_id, 0, 8)
  lambda_arn         = module.lambda-check.lambda_arn
  azs                = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  lab_bucket_name    = "${local.name_prefix}-bucket"
  user_id            = "sailor-${local.name_prefix}"
  object_name        = "index.html"
  lab_script_path    = "./my-script.sh"

  ami_name = "ami-terminal"

  metadata_config = yamldecode(file("${path.module}/metadata.yml"))

  public_key_rsa     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwD9+3+VWOp0sdpPBNWlzp38Vr457u03A/BRkiYV+c9mSBMhSu7fgbBrXh8Wv9m6YMDi/LW8EeQ/KB3Gc0WMpXA2VLyQeqLQGmVbkymKXXElOPOLk2Dp7zrJuWVZ0tuLNoq66/XUt06VvN4hVnZlTPaB+7Cgm4vCK862r9k1boY28V8OlSJMuxYjVQRn/ivrFwWIpZOlr4EWRjJSbyHhayaOFk08BfKOaXdPbR2pLu0m9G1QBgetvy1brEOlkTpObqwWDmC5gK3N+kBWNJjfcn5gPUWcKvTU9tcXGRmqoGAET4dU8IBA3BGEZ76MImUfeA5jAKkUxMw2A3UBj9mTEkiojQKa6KzrmWfWd9mEgkuaA5zVEdYv8qXOBLuj9bNlHaDREjwXhQ8TkqFn9Tety21WWRc16ds1vhjgHocgw1SjsJocgwukVprMtzQ+Y+GlvcOEo26aNEOWdasV37vfuyvcUoJD5fiQVcgSWFpCTBQIg47uE6JOffd/d2UG+WNx8= houssein@houssein-GL553VD"
  top_level_domain   = "thehotpirate.com"
  domain_name        = "terminal.scalyz.test.thehotpirate.com"
  module_path_prefix = "/mnt/efs/modules"
}
