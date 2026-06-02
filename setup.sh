#!/bin/bash
set -e

REGION="us-east-1"
FUNCTION_NAME="ec2-control"

echo "==> 1. Creation de l'instance EC2"
INSTANCE_ID=$(awslocal ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type t2.micro \
  --count 1 \
  --query "Instances[0].InstanceId" --output text)
echo "    Instance creee : $INSTANCE_ID"

echo "==> 2. Zip de la Lambda"
cd lambda
zip -r function.zip lambda_function.py > /dev/null
cd ..

echo "==> 3. Creation de la fonction Lambda"
awslocal lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime python3.11 \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda/function.zip \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --timeout 30 > /dev/null
echo "    Lambda '$FUNCTION_NAME' creee"

echo "==> 4. Attente que la Lambda soit prete"
awslocal lambda wait function-active --function-name $FUNCTION_NAME

echo "==> 5. Creation de l'API Gateway"
API_ID=$(awslocal apigateway create-rest-api --name "ec2-api" --query "id" --output text)
ROOT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query "items[0].id" --output text)
RESOURCE_ID=$(awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part "ec2" \
  --query "id" --output text)
echo "    API creee : $API_ID"

echo "==> 6. Creation de la methode GET"
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type "NONE" > /dev/null

echo "==> 7. Integration de la Lambda (AWS_PROXY)"
awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${REGION}:000000000000:function:${FUNCTION_NAME}/invocations" > /dev/null

echo "==> 8. Permission API Gateway -> Lambda"
awslocal lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id apigw-access \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com > /dev/null

echo "==> 9. Deploiement de l'API (stage dev)"
awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name dev > /dev/null

echo ""
echo "============================================="
echo " Infrastructure prete !"
echo " Instance EC2 : $INSTANCE_ID"
echo " API ID       : $API_ID"
echo ""
echo " Tester avec :"
echo " curl \"http://localhost:4566/_aws/execute-api/$API_ID/dev/ec2?action=stop&instance_id=$INSTANCE_ID\""
echo " curl \"http://localhost:4566/_aws/execute-api/$API_ID/dev/ec2?action=start&instance_id=$INSTANCE_ID\""
echo "============================================="