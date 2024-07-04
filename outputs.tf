locals {
  workspace              = terraform.workspace
  username               = module.user-sts.username
  user_access_key_id     = module.user-sts.user_access_key_id
  user_access_key_secret = module.user-sts.user_access_key_secret
  password               = module.user-sts.password
  terminal_ec2_id        = module.lab-terminal.ec2_id
  terminal_url           = module.lab-terminal.terminal_url
  target_role_arn        = var.target_role_arn
  lab_instance_id        = var.instance_id
  submit_url = "https://feedback.${var.platform_base_domain}/qcm/${var.instance_id}"
}


locals {

  content_1 = {
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

  content_2 = {
    type    = "content",
    content = <<EOF
    1. In the AWS Management Console dashboard, type "S3" into the search bar and select **Amazon S3** from the search results.
    2. Select the region `${local.region}` on the top right side of AWS console.
    3. Click on the **Create bucket** button.
    3. Follow the prompts to configure your bucket:
      - Enter the following bucket name: `${local.lab_bucket_name}`
      - Do not modify the options for versioning, logging, and encryption based on the lab requirements.
      - Review and confirm your settings.
    4. After the bucket is created, verify that it appears in the S3 dashboard.
    EOF
  }

  content_3 = {
    type    = "content",
    content = <<EOF
    1. Open your terminal or command prompt.
    2. Configure AWS CLI with your AWS credentials by running the following command:
      ```
      aws configure
      ```
      - Access Key ID: `${local.user_access_key_id}`
      - Secret Access Key: `${local.user_access_key_secret}`
      - Region: `${local.region}`
      - Output format should stay default.
    4. Verify the configuration by executing a simple AWS CLI command, such as listing S3 buckets:
      ```
      aws s3 ls
      ```
    5. Ensure that you can successfully execute AWS CLI commands.
    EOF
  }

  content_4 = {
    type    = "content",
    content = <<EOF
    1. You will be provided with a file to upload to the S3 bucket.
    2. Open your terminal or command prompt and create a new file `${local.object_name}` with the following content :
      ```
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Hello</title>
          <style>
              body {
                  font-family: Arial, sans-serif;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  margin: 0;
                  background-color: #f0f0f0;
              }
              .container {
                  text-align: center;
                  background-color: #fff;
                  padding: 20px;
                  border-radius: 8px;
                  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
              }
          </style>
      </head>
      <body>
          <div class="container">
              <h1>Hello, World!</h1>
              <p>Welcome to my website hosted on S3 ${local.lab_bucket_name}</p>
          </div>
      </body>
      </html>
      ```
    3. Use AWS CLI to upload the file to the S3 bucket by running the following command:
      ```
      aws s3 cp ${local.object_name} s3://${local.lab_bucket_name}/
      ```
    4. Copy the previous command to the file `${local.lab_script_path}`
    5. Verify that the file has been successfully uploaded by checking the S3 bucket through the AWS Management Console or using AWS CLI commands.
    EOF
  }

  content_5 = {
    type    = "content",
    content = <<EOF
    1. In the S3 dashboard, click on the name of the bucket you created: `${local.lab_bucket_name}`.
    2. Click on the "Properties" tab.
    3. Find the "Versioning" card and click "Edit".
    4. Select "Enable" and click "Save changes".
    EOF
  }

  content_6 = {
    type    = "content",
    content = <<EOF
    1. Still in the bucket dashboard, click on the "Permissions" tab.
    2. Scroll down to find the "Block public access (bucket settings)" section and click "Edit".
    3. Uncheck all options to disable block public access settings.
    4. Click "Save changes" and confirm by typing "confirm".
    EOF
  }

  content_7 = {
    type    = "content",
    content = <<EOF
    1. Within the "Permissions" tab, click on "Bucket policy".
    2. Enter the following policy:
      ```
      {   
        "Version": "2012-10-17",   
        "Statement": [     
          {       
            "Sid": "PublicReadGetObject",       
            "Effect": "Allow",       
            "Principal": "*",       
            "Action": "s3:GetObject",       
            "Resource": ["arn:aws:s3:::${local.lab_bucket_name}/*", "arn:aws:s3:::${local.lab_bucket_name}"]     
          }   
        ] 
      }
      ```
    3. Click "Save changes".
    EOF
  }

  content_9 = {
    type    = "content",
    content = <<EOF
    1. Go back to the S3 dashboard and click on the name of your bucket.
    2. Click on the "Properties" tab.
    3. Scroll down to the "Static website hosting" card and click "Edit".
    4. Select "Enable" and fill in `index.html` for both the "Index document" and "Error document".
    5. Click "Save changes".
    6. Access your website on the following link: http://${local.lab_bucket_name}.s3-website.${local.region}.amazonaws.com/index.html
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
    submit_url = local.submit_url
  }

  content_qcm_2 = {
    type  = "qcm"
    id    = "qcm-2"
    answers_type = "single"
    title = "What AWS CLI command is used to upload a file to an S3 bucket?"
    proposed_answers = [
      "aws s3 cp localfile.txt s3://yourbucketname",
      "aws s3 upload localfile.txt s3://yourbucketname",
      "aws s3 move localfile.txt s3://yourbucketname",
      "aws s3 put localfile.txt s3://yourbucketname"
    ],
    submit_url = local.submit_url
  }

  content_qcm_3 = {
    type  = "qcm"
    id    = "qcm-3"
    answers_type = "single"
    title = "Why is it important to enable versioning on an S3 bucket?"
    proposed_answers = [
      "To increase the storage capacity of the bucket.",
      "To keep multiple versions of an object in the same bucket.",
      "To configure the bucket as a static website.",
      "To secure the bucket with encryption."
    ],
    submit_url = local.submit_url
  }

  terminal_1 = {
    type = "terminal",
    url  = local.terminal_url
  }

}



output "provision_output" {
  description = "Platform outputs"
  sensitive   = true
  value = [
    {
      title       = "Accessing the AWS Management Console"
      description = "Learn how to log into and navigate the AWS Management Console, enabling efficient management and operation of AWS."
      type        = "goal"
      value       = jsonencode([local.content_1])
    },
    {
      title       = "Create S3 Bucket"
      description = "Learn how to create and configure an S3 bucket using the AWS Management Console."
      type        = "goal"
      value       = jsonencode([local.content_2])
    },

    {
      title       = "Configure AWS CLI"
      description = "Instructions on configuring the AWS Command Line Interface with your credentials."
      type        = "goal"
      value       = jsonencode([local.content_3, local.terminal_1])
    },

    {
      title       = "Upload File via AWS CLI"
      description = "Detailed steps on how to upload a file to your S3 bucket using AWS CLI commands."
      type        = "goal"
      value       = jsonencode([local.content_4, local.terminal_1])
    },

    {
      title       = "Enable Versioning on S3 Bucket"
      description = "Guide to enable versioning for an S3 bucket through the AWS Management Console."
      type        = "goal"
      value       = jsonencode([local.content_5])
    },

    {
      title       = "Disable Public Block Settings"
      description = "Step-by-step instructions to disable public block settings in an S3 bucket."
      type        = "goal"
      value       = jsonencode([local.content_6])
    },

    {
      title       = "Set Bucket Policy"
      description = "Learn how to set a bucket policy to allow public read access using JSON format."
      type        = "goal"
      value       = jsonencode([local.content_7])
    },

    {
      title       = "Enable Static Website Hosting"
      description = "Guide to enable static website hosting for an S3 bucket to serve web pages."
      type        = "goal"
      value       = jsonencode([local.content_9])
    },

    {
      title       = "AWS S3 Configuration QCM"
      description = "Multiple-choice questions covering the configuration and management of Amazon S3 buckets, including naming conventions, file uploading, and versioning."
      type        = "goal"
      value       = jsonencode([
        local.content_qcm_title,
        local.content_qcm_1,
        local.content_qcm_2,
        local.content_qcm_3
      ])
    }
  ]
}