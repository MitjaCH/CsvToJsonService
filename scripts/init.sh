#!/bin/bash

# Load YAML Configuration
CONFIG_FILE="config.yml"

if ! command -v yq &> /dev/null; then
  echo "yq not found. Please install it: https://github.com/mikefarah/yq"
  exit 1
fi

# Parse config values
REGION=$(yq '.region' $CONFIG_FILE | tr -d '"')
ROLE_ARN=$(yq '.role_arn' $CONFIG_FILE | tr -d '"')
LAMBDA_FUNCTION_NAME=$(yq '.lambda_function_name' $CONFIG_FILE | tr -d '"')
LAMBDA_HANDLER=$(yq '.lambda_handler' $CONFIG_FILE | tr -d '"')
LAMBDA_RUNTIME=$(yq '.lambda_runtime' $CONFIG_FILE | tr -d '"')
ZIP_FILE=$(yq '.zip_file' $CONFIG_FILE | tr -d '"')
LAMBDA_FILE=$(yq '.lambda_file' $CONFIG_FILE | tr -d '"')

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
if [ $? -ne 0 ]; then
  echo "Failed to create input bucket: ${IN_BUCKET_NAME}"
  exit 1
fi

aws s3 mb "s3://${OUT_BUCKET_NAME}" --region ${REGION}
if [ $? -ne 0 ]; then
  echo "Failed to create output bucket: ${OUT_BUCKET_NAME}"
  exit 1
fi
echo "S3 buckets ${IN_BUCKET_NAME} and ${OUT_BUCKET_NAME} created."

# Prepare Lambda function
echo "Zipping Lambda function..."
zip -r ${ZIP_FILE} ${LAMBDA_FILE} node_modules
if [ $? -ne 0 ]; then
  echo "Failed to zip Lambda function."
  exit 1
fi

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

if [ $? -ne 0 ]; then
  echo "Failed to create Lambda function: ${LAMBDA_FUNCTION_NAME}"
  exit 1
fi
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

if [ $? -ne 0 ]; then
  echo "Failed to add permissions for S3 to invoke Lambda."
  exit 1
fi

# Wait for permissions to propagate
echo "Waiting 15 seconds for permissions to propagate..."
sleep 15

# Add S3 trigger
echo "Adding S3 trigger..."
LAMBDA_ARN=$(aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --query 'Configuration.FunctionArn' --output text)
if [ $? -ne 0 ]; then
  echo "Failed to retrieve Lambda ARN."
  exit 1
fi

aws s3api put-bucket-notification-configuration --bucket ${IN_BUCKET_NAME} --notification-configuration "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\": \"${LAMBDA_ARN}\",
      \"Events\": [\"s3:ObjectCreated:*\"] 
    }
  ]
}"
if [ $? -ne 0 ]; then
  echo "Failed to add S3 trigger."
  exit 1
fi
echo "Lambda trigger added: Uploads to ${IN_BUCKET_NAME} will be automatically processed."
echo "Setup complete!"
echo "In-Bucket: ${IN_BUCKET_NAME}"
echo "Out-Bucket: ${OUT_BUCKET_NAME}"

# Verify bucket notification configuration
echo "Verifying bucket notification configuration..."
aws s3api get-bucket-notification-configuration --bucket ${IN_BUCKET_NAME}

# Create a sample CSV file
CSV_FILE="sample.csv"
echo "id,name,age" > ${CSV_FILE}
echo "1,John,30" >> ${CSV_FILE}
echo "2,Jane,25" >> ${CSV_FILE}
echo "3,Bob,40" >> ${CSV_FILE}
echo "Sample CSV file ${CSV_FILE} created."

# Upload CSV file to the input bucket
echo "Uploading sample CSV file to ${IN_BUCKET_NAME}..."
aws s3 cp ${CSV_FILE} s3://${IN_BUCKET_NAME}/
if [ $? -ne 0 ]; then
  echo "Failed to upload sample CSV file."
  exit 1
fi

# Wait for processing to complete
echo "Waiting for processing to complete..."
sleep 10

# Download the processed JSON from the output bucket
JSON_FILE="converted/sample.json"
echo "Downloading processed JSON from ${OUT_BUCKET_NAME}..."
aws s3 cp s3://${OUT_BUCKET_NAME}/${JSON_FILE} ${JSON_FILE}

if [ -f "${JSON_FILE}" ]; then
  echo "Processed JSON file downloaded: ${JSON_FILE}"
  cat ${JSON_FILE}
else
  echo "Processed JSON file not found. Check the Lambda logs for errors."
fi
