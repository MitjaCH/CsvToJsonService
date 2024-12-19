#!/bin/bash

# Load YAML Configuration
CONFIG_FILE="config.yml"

if ! command -v yq &> /dev/null; then
  echo "yq not found. Please install it: https://github.com/mikefarah/yq"
  exit 1
fi

REGION=$(yq '.region' $CONFIG_FILE)
ROLE_ARN=$(yq '.role_arn' $CONFIG_FILE)
LAMBDA_FUNCTION_NAME=$(yq '.lambda_function_name' $CONFIG_FILE)
LAMBDA_HANDLER=$(yq '.lambda_handler' $CONFIG_FILE)
LAMBDA_RUNTIME=$(yq '.lambda_runtime' $CONFIG_FILE)
ZIP_FILE=$(yq '.zip_file' $CONFIG_FILE)
LAMBDA_FILE=$(yq '.lambda_file' $CONFIG_FILE)

# Generate unique bucket names
IN_BUCKET_NAME="csv-to-json-in-$(date +%s)"
OUT_BUCKET_NAME="csv-to-json-out-$(date +%s)"

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
zip -r ${ZIP_FILE} ${LAMBDA_FILE} node_modules

# Create Lambda function
echo "Creating Lambda function..."
aws lambda create-function \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --runtime ${LAMBDA_RUNTIME} \
  --role ${ROLE_ARN} \
  --handler ${LAMBDA_HANDLER} \
  --zip-file fileb://${ZIP_FILE} \
  --region ${REGION} \
  --environment "Variables={INPUT_BUCKET=${IN_BUCKET_NAME},OUTPUT_BUCKET=${OUT_BUCKET_NAME}}"

echo "Lambda function ${LAMBDA_FUNCTION_NAME} created."

# Add Lambda permissions for S3
echo "Adding Lambda permissions for S3..."
aws lambda add-permission \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::${IN_BUCKET_NAME} \
  --source-account $(aws sts get-caller-identity --query Account --output text)

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

# Verify bucket notification configuration
echo "Verifying bucket notification configuration..."
aws s3api get-bucket-notification-configuration --bucket ${IN_BUCKET_NAME}
