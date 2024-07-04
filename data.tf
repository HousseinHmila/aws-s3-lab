data "aws_caller_identity" "current" {}


data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "s3_full_access_policy" {
  statement {
    sid    = "S3FullAccess"
    effect = "Allow"

    actions = [
      "s3:*"
    ]

    resources = [
      "arn:aws:s3:::${local.lab_bucket_name}",
      "arn:aws:s3:::${local.lab_bucket_name}/*",
    ]
  }
  statement {
    sid    = "S3CreateAllBuckets"
    effect = "Allow"

    actions = [
      "s3:CreateBucket"
    ]

    resources = [
      "*"
    ]
  }
}