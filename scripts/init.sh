#!/bin/bash
set -e  # Exit on error
set -x  # Debug mode

# Variables
REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-$(date +%s)"
OUT_BUCKET_NAME="csv-to-json-out-$(date +%s)"
LAMBDA_FUNCTION_NAME="CsvToJsonConverter"
ROLE_ARN="arn:aws:iam::474281778567:role/LabRole"
ZIP_FILE="lambda_function_payload.zip"
LAMBDA_FILE="dist/index.js"

# Install dependencies and compile TypeScript
echo "Installing dependencies and compiling TypeScript..."
npm install
npx tsc

# Create S3 buckets
echo "Creating S3 buckets..."
aws s3 mb "s3://${IN_BUCKET_NAME}" --region ${REGION}
aws s3 mb "s3://${OUT_BUCKET_NAME}" --region ${REGION}
echo "S3 buckets ${IN_BUCKET_NAME} and ${OUT_BUCKET_NAME} created."

# Prepare Lambda function
echo "Zipping Lambda function..."
zip -j ${ZIP_FILE} ${LAMBDA_FILE}

# Create Lambda function
echo "Creating Lambda function..."
aws lambda create-function \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --runtime nodejs18.x \
  --role ${ROLE_ARN} \
  --handler index.lambdaHandler \
  --zip-file fileb://${ZIP_FILE} \
  --region ${REGION} \
  --environment "Variables={OUTPUT_BUCKET=${OUT_BUCKET_NAME}}"

echo "Lambda function ${LAMBDA_FUNCTION_NAME} created."

# Add Lambda permissions for S3
echo "Adding Lambda permissions for S3..."
aws lambda add-permission \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::${IN_BUCKET_NAME} \
  --source-account 474281778567

# Wait for permissions to propagate
echo "Waiting 5 seconds for permissions to propagate..."
sleep 5

# Add S3 trigger
echo "Adding S3 trigger..."
aws s3api put-bucket-notification-configuration --bucket ${IN_BUCKET_NAME} --notification-configuration "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\": \"$(aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --query 'Configuration.FunctionArn' --output text)\",
      \"Events\": [\"s3:ObjectCreated:*\"] 
    }
  ]
}"

echo "Lambda trigger added: Uploads to ${IN_BUCKET_NAME} will be automatically processed."
echo "Setup complete!"
echo "In-Bucket: ${IN_BUCKET_NAME}"
echo "Out-Bucket: ${OUT_BUCKET_NAME}"
