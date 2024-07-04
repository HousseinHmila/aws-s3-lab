import boto3
import os
import json
import urllib.request
import time


AWS_REGION = os.environ["AWS_REGION"]
INSTANCE_ID = os.environ["INSTANCE_ID"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
OBJECT_NAME = os.environ["OBJECT_NAME"]
USER_ACCESS_KEY_ID = os.environ["USER_ACCESS_KEY_ID"]
USER_ACCESS_KEY_SECRET = os.environ["USER_ACCESS_KEY_SECRET"]
SCRIPT_PATH = os.environ["SCRIPT_PATH"]
LINUX_USER = os.environ["LINUX_USER"]
LAB_USER = os.environ["LAB_USER"]
LAB_INSTANCE_ID = os.environ["LAB_INSTANCE_ID"]
sns_topic_arn = os.environ["SNS_TOPIC_ARN"]

# Create an EC2 client
ec2_client = boto3.client('ec2')
ssm_client = boto3.client('ssm', region_name=AWS_REGION)
s3_client = boto3.client('s3')
cloudtrail_client = boto3.client('cloudtrail')
sns_client = boto3.client('sns')



def send_message_to_sns(message, sns_topic_arn):
    try:
        print(f"Sending to SNS topic: {sns_topic_arn}")
        # Publish a message to the specified SNS topic
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps({'default': json.dumps(message)}),
            MessageStructure='json'
        )

        return response

    except Exception as e:
        # Handle the exception (print or log the error, raise an exception, etc.)
        print(f"Error sending message to SNS topic: {e}")
        raise


def check_s3_bucket(bucket_name):

    is_bucket_created = False

    try:
        # Attempt to get the bucket's location (this will raise an error if the bucket does not exist)
        response = s3_client.head_bucket(Bucket=bucket_name)
        http_code = response['ResponseMetadata']['HTTPStatusCode']

        print(f"HTTP code bucket: {http_code}")

        if http_code == 200:
            is_bucket_created = True
        
        return is_bucket_created
    except Exception as e:
        print(f"Error: {e}")
        return False

def check_s3_object(bucket_name, key):
    """
    Check if an object exists in an S3 bucket.

    Args:
    - bucket_name (str): The name of the S3 bucket.
    - key (str): The key of the object to check.

    Returns:
    - bool: True if the object exists, False otherwise.
    """

    is_object_created = False
    
    try:
        # Attempt to head the object (this will raise an error if the object does not exist)
        response = s3_client.head_object(Bucket=bucket_name, Key=key)
        http_code = response['ResponseMetadata']['HTTPStatusCode']

        print(f"HTTP code object: {http_code}")

        if http_code == 200:
            is_object_created = True
        
        return is_object_created
    except Exception as e:
        print(f"Error: {e}")
        return False

def check_cloudtrail_for_user_event(user_name, event_name):

    is_event = False

    try:
        end_time = time.time()
        start_time = end_time - 1800

        # Get the most recent CloudTrail events within the last 30 minutes
        response = cloudtrail_client.lookup_events(
            LookupAttributes=[
                {
                    'AttributeKey': 'EventName',
                    'AttributeValue': event_name
                },
                {
                    'AttributeKey': 'Username',
                    'AttributeValue': user_name
                }
            ],
            StartTime=start_time,
            EndTime=end_time,
            MaxResults=10
        )
        # Check if there are any events
        events = response.get('Events', [])
        if events:
            for event in events:
                # Extract relevant information from the event
                event_name = event['EventName']
                event_time = event['EventTime']
                event_source = event['EventSource']
                event_username = event['Username']
                
                if event_username == user_name:
                    is_event = True
                # Print or process the event information
                print(f"Event Name: {event_name}, Event Time: {event_time}, Event Source: {event_source}, Event User: {event_username}")
            
        else:
            print("No S3 ListBucket events found for the specified user.")
        return is_event

    except Exception as e:
        print(f"Error: {e}")
        return False

def check_bucket_versioning(bucket_name):
    """
    Check if versioning is enabled for the specified S3 bucket.

    Args:
    - bucket_name (str): The name of the S3 bucket.

    Returns:
    - bool: True if versioning is enabled, False otherwise.
    """
    try:
        # Create a Boto3 S3 client
        s3_client = boto3.client('s3')

        # Get the bucket versioning configuration
        response = s3_client.get_bucket_versioning(Bucket=bucket_name)

        # Check if versioning is enabled
        if 'Status' in response and response['Status'] == 'Enabled':
            return True
        else:
            return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def check_public_access_block(bucket_name):
    """Check the Public Access Block configuration of an S3 bucket."""

    is_publicly_accessible = False

    try:
        response = s3_client.get_public_access_block(
            Bucket=bucket_name
        )
        public_access_block_configuration = response['PublicAccessBlockConfiguration']

        block_public_acls = public_access_block_configuration['BlockPublicAcls']
        ignore_public_acls = public_access_block_configuration['IgnorePublicAcls']
        block_public_policy = public_access_block_configuration['BlockPublicPolicy']
        restrict_public_buckets = public_access_block_configuration['RestrictPublicBuckets']

        if (not block_public_acls) and (not ignore_public_acls) and (not block_public_policy) and (not restrict_public_buckets):
            is_publicly_accessible = True

        return is_publicly_accessible
    except Exception as e:
        print(f"Failed to retrieve Public Access Block configuration for bucket {bucket_name}: {e}")
        return False

def compare_bucket_policy(bucket_name, expected_policy_json):

    is_policy_correct = False

    try:
        # Attempt to get the bucket policy
        response = s3_client.get_bucket_policy(Bucket=bucket_name)
        current_policy_json = json.loads(response['Policy'])
        
        # Convert both policies to JSON objects for comparison

        print(f"Current bucket policy: {current_policy_json}")

        print(f"File policy: {expected_policy_json}")
        # Compare the policies
        if current_policy_json == expected_policy_json:
            print("The bucket policy matches the expected policy.")
            is_policy_correct = True
        else:
            print("The bucket policy does not match the expected policy.")
        return is_policy_correct   

    except Exception as e:
        print(f"An error occurred: {e}")
        return False

def load_policy_from_file(file_path):
    try:
        with open(file_path, 'r') as file:
            policy_json = json.load(file)
            return policy_json
    except FileNotFoundError:
        print("File not found.")
        return None
    except json.JSONDecodeError:
        print("Error decoding JSON from file.")
        return None

def check_static_website(bucket_name, region):

    is_static_website_active = False

    try:

        response = urllib.request.urlopen(f"http://{bucket_name}.s3-website.{region}.amazonaws.com/index.html",timeout=3).getcode()

        print(f"\tCommand Output: {response}")

        if response == 200:
            print(f"Static Website is active")
            is_static_website_active = True
        else:
            print(f"Static Website is not active")

        return is_static_website_active
    except Exception as e:
        print(f"Error: {e}")
        return is_static_website_active

def lambda_handler(event, context):

    

    print("--------------------------- Testing Instance State ---------------------------")

    is_s3_bucket_created = check_s3_bucket(BUCKET_NAME)

    is_s3_object_created = check_s3_object(BUCKET_NAME, OBJECT_NAME)
    
    is_cli_configured = check_cloudtrail_for_user_event(LAB_USER, "ListBuckets")

    is_versioning_enabled = check_bucket_versioning(BUCKET_NAME)

    is_publicly_accessible = check_public_access_block(BUCKET_NAME)

    file_path = 'policy.json'
    policy_json = load_policy_from_file(file_path)

    is_policy_correct = compare_bucket_policy(BUCKET_NAME, policy_json)

    is_s3_index_created = check_s3_object(BUCKET_NAME, "index.html")

    is_static_website_active = check_static_website(BUCKET_NAME, AWS_REGION)

    result = {
        'statusCode': 200,
        'bucket_created' : is_s3_bucket_created,
        'object_created' : is_s3_object_created,
        'aws_cli_configured' : is_cli_configured,
        'versioning_enabled' : is_versioning_enabled,
        'public_access' : is_publicly_accessible,
        'bucket_policy_set' : is_policy_correct,
        's3_index_created' : is_s3_index_created,
        'static_website_configured' : is_static_website_active
    }
    
    data_dict = {
        "data": result,
        "instance_id": LAB_INSTANCE_ID,
        "level": 0,
        "title": "string",
        "type": "string"
    }

    response = send_message_to_sns(data_dict, sns_topic_arn)

    return response