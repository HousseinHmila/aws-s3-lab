resource "null_resource" "function_change" {
  triggers = {
    function = filesha256("${path.cwd}/function/index.py")
  }
}

resource "archive_file" "init" {
  type        = "zip"
  source_dir  = "${path.cwd}/function"
  output_path = "${path.cwd}/function.zip"

  lifecycle {
    replace_triggered_by = [null_resource.function_change]
  }
  depends_on = [local_file.bucket_policy]
}

resource "null_resource" "qcm_function_change" {
  triggers = {
    function = filesha256("${path.cwd}/qcm-function/index.py")
  }
}

resource "archive_file" "qcm_init" {
  type        = "zip"
  source_dir  = "${path.cwd}/qcm-function"
  output_path = "${path.cwd}/qcm-function.zip"

  lifecycle {
    replace_triggered_by = [null_resource.qcm_function_change]
  }
}

resource "local_file" "bucket_policy" {
  content  = templatefile("${path.cwd}/policy.tpl", { bucket_name = local.lab_bucket_name })
  filename = "${path.module}/function/policy.json"
}

module "lambda-check" {
  source = "/mnt/efs/modules/terraform-module-lab-evaluation"
    function_file_path                = archive_file.init.output_path
  lab_instance_id                   = var.instance_id
  platform_account_id = var.platform_account_id
  lambda_execution_managed_policies = ["AmazonS3FullAccess", "AmazonSNSFullAccess"]
  lambda_env_vars = {
    INSTANCE_ID            = module.lab-terminal.ec2_id
    BUCKET_NAME            = local.lab_bucket_name
    OBJECT_NAME            = local.object_name
    USER_ACCESS_KEY_ID     = module.user-sts.user_access_key_id
    USER_ACCESS_KEY_SECRET = module.user-sts.user_access_key_secret
    SCRIPT_PATH            = var.script_path
    LINUX_USER             = var.linux_user
    LAB_INSTANCE_ID        = var.instance_id
    LAB_USER               = local.user_id
    SNS_TOPIC_ARN          = var.sns_feedback_relay_arn
  }

  depends_on = [module.lab-terminal]
}


module "lambda-qcm-check" {
  source = "/mnt/efs/modules/terraform-module-lab-evaluation"
    name_suffix                       = "qcm"
  function_file_path                = archive_file.qcm_init.output_path
  platform_account_id = var.platform_account_id
  lab_instance_id                   = var.instance_id
  lambda_execution_managed_policies = ["AmazonS3FullAccess", "AmazonSNSFullAccess"]
  lambda_env_vars = {
    LAB_INSTANCE_ID = var.instance_id
    LAB_EVENT_TYPE  = "qcm"
    RESULT_TITLE    = "qcm-answer"
    SNS_TOPIC_ARN   = var.sns_feedback_relay_arn
  }


  depends_on = [module.lab-terminal]
}