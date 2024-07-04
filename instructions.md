Terraform Lab Instructions
==========================

Introduction
------------

QCM evaluation Lambda function name should be named by "qcm-${var.instance_id}"

This document provides a step-by-step guide on how to set up and execute a Terraform lab. It covers specifying providers, formatting output for users, creating a metadata.yml file, and using Terraform modules provided by the platform.

1. Specifying Providers
-----------------------

To create Terraform resources, you need to specify the different providers along with the region variable and assume role necessary for permissions. For instance, you need to specify `target_role_arn` to have permissions to create resource on the AWS Lab account and `dns_role_arn` to create a DNS record in the plateform's Route53 hosted zone.

Here's an example of how to specify providers:
```csharp
  provider "aws" {
    region = var.region
    assume_role {
      role_arn = var.target_role_arn
    }
  }

  provider "aws" {
    alias  = "dns"
    region = var.region
    assume_role {
      role_arn = var.dns_role_arn
    }
  }
```
2. Formatting Output for Users
-----------------------------

All necessary information for the user to complete the lab, such as goals, terminal commands, and access instructions, should be presented in a single output. This output should be formatted as a list of maps, where each map contains the following keys:
    title: a short, descriptive title for the information being presented
    description: a more detailed explanation of the information
    type: the type of information being presented. This should always be set to "goal".
    value: the actual content of the information, formatted as a JSON object. The value object can have one of two types:
    content: textual information to be displayed to the user, such as a description of a goal or instructions for accessing a resource.
    terminal: a terminal command that the user should run to complete a goal.


Here's an example of how to format the output:
```csharp
locals{
    content_10 = {
    type    = "content",
    content = <<EOF
      1. Open your web browser.
      2. Go to the AWS Management Console login page by typing the following URL into your browser's address bar: [AWS Management Console](https://console.aws.amazon.com/console/home)
      3. Select **IAM User** option.
      4. Type in the following AWS Account ID: `${local.current_account_id}`
      5. Sign in using the following AWS account credentials.
          - IAM User Name: `${local.username}`
          - Password: `${local.password}`
      6. Once logged in, you should be directed to the AWS Management Console dashboard. If not, navigate to the dashboard.
    EOF
  }


  content_qcm_title = {
    content = "Multiple questions to test your S3 knowledge."
    type = "content"
  }


  content_qcm_1 = {
    type  = "qcm"
    id    = "qcm-1"
    answers_type = "single"
    title = "Which of the following is a valid requirement for naming an Amazon S3 bucket?"
    proposed_answers = [
      "Must start and end with a lowercase letter or number.",
      "Must be unique across all existing bucket names in Amazon S3.",
      "Can include underscores (_) and ampersands (&).",
      "There is no requirement; any name is acceptable as long as it is not already taken."
    ],
    submit_url = "https://feedback.${var.platform_base_domain}/qcm/${var.instance_id}"
  }

  terminal_1 = {
    type = "terminal",
    url  = local.terminal_url
  }
}
output "lab_instructions" {
  description = "Platform outputs"
  value = [
    {
      title       = "Accessing the AWS Management Console"
      description = "Learn how to log into and navigate the AWS Management Console, enabling efficient management and operation of AWS."
      type        = "goal"
    value = jsonencode([local.content_1, local.terminal_1]) },

    {
      title       = "AWS S3 Configuration QCM"
      description = "Multiple-choice questions covering the configuration and management of Amazon S3 buckets, including naming conventions, file uploading, and versioning."
      type        = "goal"
      value       = jsonencode([
        local.content_qcm_title,
        local.content_qcm_1
      ])
    }
  ]
}
```
3. Creating a metadata.yml File
-------------------------------

You need to create a metadata.yml file that contains the following fields:

* `name` (the name of the lab)
* `lab_name` (the name of the lab formatted in lowercase and with dashes instead of spaces)
* `owner_username`
* `owner_fullname`
* `duration` (the duration of the lab)
* `goals` (a list of goals for the lab, with each element containing a description and tasks)
* `learned_skills` (a list of skills that will be learned in the lab)
* `tags` (all technologies used in the lab, e.g., AWS, S3, Lambda)

Here's an example of how to create a metadata.yml file:
```yaml
name: Creating an S3 Bucket
lab_name: creating-an-s3-bucket
owner_username: jdoe
owner_fullname: John Doe
duration: 30 minutes
goals:
  - description: Create an S3 bucket
    tasks:
      - Use the AWS CLI to create an S3 bucket
      - Verify that the bucket was created
  - description: Upload an object to the S3 bucket
    tasks:
      - Use the AWS CLI to upload an object to the S3 bucket
      - Verify that the object was uploaded
learned_skills:
  - AWS CLI
  - S3
tags:
  - AWS
  - S3
```
4. Using Terraform Modules
--------------------------

You should use the Terraform modules provided by the platform to create the AWS user, terminal (if necessary for the lab user to execute commands), and Lambda function for verifying lab results. You should also create a local variable with a list of IAM policies that the user will need to have associated with their role.

Here's an example of how to use Terraform modules:
```csharp
module "aws_user" {
  source = "github.com/example/terraform-aws-user"
  username = "jdoe"
  policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]
}
```

5. Configuring Lambda Evaluation Module

For the execution of Lambda functions that are part of the lab's result verification process, it is crucial to correctly configure the environment variables. These variables ensure that the Lambda function has all the necessary information to perform its tasks, such as identifying the specific lab instance and communicating results via AWS SNS.

Below is an example of how to set up the environment variables using Terraform modules:

```csharp
module "lambda_evaluation" {
  source = "github.com/example/terraform-aws-lambda"
  function_name = "lab_result_verifier"
  lambda_env_vars = {
    LAB_INSTANCE_ID = var.instance_id
    SNS_TOPIC_ARN   = var.sns_feedback_relay_arn
  }
}

Conclusion
----------

In this document, we covered how to specify providers, format output for users, create a metadata.yml file, and use Terraform modules provided by the platform. By following these instructions, you should be able to set up and execute a Terraform lab successfully.