import json
import boto3


def lambda_handler(event, context):
    # 1. Récupérer l'action et l'instance_id depuis la requête
    params = event.get("queryStringParameters") or {}
    action = params.get("action")
    instance_id = params.get("instance_id")

    # 2. Se connecter à EC2 via l'endpoint INTERNE de LocalStack
    ec2 = boto3.client(
        "ec2",
        endpoint_url="http://localstack-main:4566",
        region_name="us-east-1",
        aws_access_key_id="test",
        aws_secret_access_key="test",
    )

    # 3. Exécuter l'action demandée
    if action == "start":
        ec2.start_instances(InstanceIds=[instance_id])
        message = f"Instance {instance_id} demarree"
    elif action == "stop":
        ec2.stop_instances(InstanceIds=[instance_id])
        message = f"Instance {instance_id} arretee"
    else:
        return {
            "statusCode": 400,
            "body": json.dumps({"erreur": "action invalide, utilise start ou stop"}),
        }

    # 4. Réponse HTTP au format attendu par API Gateway
    return {
        "statusCode": 200,
        "body": json.dumps({"message": message}),
    }