variable "lab_bucket_name" {
  description = "Lab's S3 bucket name"
  default     = ""
}

variable "script_path" {
  description = "Path to the shell script where command should be copied to be checked"
  default     = "/home/sailor/s3command.sh"
}

variable "linux_user" {
  default = "sailor"
}

variable "target_role_arn" {

}

variable "instance_id" {

}

variable "platform_top_level_domain" {
  
}

variable "platform_base_domain" {
  
}

variable "platform_account_id" {
  
}

variable "lab_aws_region" {

}

variable "sns_feedback_relay_arn" {

}