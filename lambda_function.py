import os
import json
import requests
import boto3

def lambda_handler(event, context):
    
    s3=boto3.client('s3')
    bucket_name = os.environ['BUCKET_NAME']
    s3_response = s3.get_object(Bucket=bucket_name, Key='role.txt')

    body = json.loads(event['body'])
    user_text = body.get('text', '')
    user_answer = body.get('answer', '')
    role = s3_response['Body'].read().decode('utf-8').strip()
    
    headers = {
        "Authorization": f"Bearer {os.environ['OPENROUTER_API_KEY']}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "deepseek/deepseek-chat-v3-0324:free",
        "messages": [
            {
                "role": "system",
                "content": role
            },
            {
                "role": "user",
                "content": f"שאלה: {user_text}\nתשובה: {user_answer}"
            }
        ]
    }

    try:
        response = requests.post("https://openrouter.ai/api/v1/chat/completions", headers=headers, json=payload)
        data = response.json()
        result = data['choices'][0]['message']['content']
    except Exception as e:
        result = f"Error: {str(e)}"

    return {
        "statusCode": 200,
        "body": json.dumps({"result": result})
    }
