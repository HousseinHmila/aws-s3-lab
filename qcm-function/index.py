import json
import boto3
import os

LAB_INSTANCE_ID = os.environ["LAB_INSTANCE_ID"]
LAB_EVENT_TYPE = os.environ["LAB_EVENT_TYPE"]
RESULT_TITLE = os.environ["RESULT_TITLE"]
sns_topic_arn = os.environ["SNS_TOPIC_ARN"]

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

def lambda_handler(event, context):
    # Define the correct answers

    json_file_path = os.path.join(os.path.dirname(__file__), 'correct_answers.json')
    
    # Read the correct answers file
    with open(json_file_path, 'r') as file:
        correct_answers = json.load(file)
    
    # Extract answers from the event
    user_answers = event.get('answers', {})

    print(f"Event: {event}")
    # Prepare the result dictionary
    results = {
        "correct": 0,
        "incorrect": 0,
        "details": []
    }

    # Compare each answer with the correct answer
    for question, answer in user_answers.items():
        if question in correct_answers:
            if answer == correct_answers[question]:
                results["correct"] += 1
                results["details"].append({
                    "question": question,
                    "user_answer": answer,
                    "correct": True
                })
            else:
                results["incorrect"] += 1
                results["details"].append({
                    "question": question,
                    "user_answer": answer,
                    "correct": False,
                    "correct_answer": correct_answers[question]
                })
        else:
            results["details"].append({
                "question": question,
                "user_answer": answer,
                "correct": False,
                "error": "Invalid question ID"
            })
    
    result = {
        "data": results,
        "instance_id": LAB_INSTANCE_ID,
        "level": 0,
        "title": RESULT_TITLE,
        "type": LAB_EVENT_TYPE
    }
    
    print(f"Results: {result}")

    response = send_message_to_sns(result, sns_topic_arn)
    # Return JSON result
    return response
