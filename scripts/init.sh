#!/bin/bash
set -e  # Beende das Skript bei Fehlern
set -x  # Debug-Modus

# Variablen
REGION="us-east-1"
IN_BUCKET_NAME="csv-to-json-in-$(date +%s)"
OUT_BUCKET_NAME="csv-to-json-out-$(date +%s)"
LAMBDA_FUNCTION_NAME="CsvToJsonConverter"
ROLE_ARN="arn:aws:iam::474281778567:role/LabRole"
ZIP_FILE="lambda_function_payload.zip"
LAMBDA_FILE="lambda_function.ts"

# S3-Buckets erstellen
echo "Erstelle S3-Buckets..."
aws s3 mb "s3://${IN_BUCKET_NAME}" --region ${REGION}
aws s3 mb "s3://${OUT_BUCKET_NAME}" --region ${REGION}
echo "S3-Buckets ${IN_BUCKET_NAME} und ${OUT_BUCKET_NAME} wurden erstellt."

# Lambda-Funktion vorbereiten
echo "Bereite Lambda-Funktion vor..."
cp ../src/index.ts ${LAMBDA_FILE}

# Lambda-Funktion zippen
echo "Zippe Lambda-Funktion..."
zip -j ${ZIP_FILE} ${LAMBDA_FILE}

# Lambda-Funktion erstellen
echo "Erstelle Lambda-Funktion..."
aws lambda create-function \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --runtime python3.9 \
  --role ${ROLE_ARN} \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://${ZIP_FILE} \
  --region ${REGION} \
  --environment "Variables={OUTPUT_BUCKET=${OUT_BUCKET_NAME}}"

echo "Lambda-Funktion ${LAMBDA_FUNCTION_NAME} wurde erstellt."

# Lambda-Berechtigungen für S3 hinzufügen
echo "Füge Lambda-Berechtigungen für S3 hinzu..."
aws lambda add-permission \
  --function-name ${LAMBDA_FUNCTION_NAME} \
  --principal s3.amazonaws.com \
  --statement-id s3invoke \
  --action "lambda:InvokeFunction" \
  --source-arn arn:aws:s3:::${IN_BUCKET_NAME} \
  --source-account 474281778567

# 5 Sekunden warten
echo "Warte 5 Sekunden..."
sleep 5

# S3-Trigger hinzufügen
echo "Füge S3-Trigger hinzu..."
aws s3api put-bucket-notification-configuration --bucket ${IN_BUCKET_NAME} --notification-configuration "{
  \"LambdaFunctionConfigurations\": [
    {
      \"LambdaFunctionArn\": \"$(aws lambda get-function --function-name ${LAMBDA_FUNCTION_NAME} --query 'Configuration.FunctionArn' --output text)\",
      \"Events\": [\"s3:ObjectCreated:*\"] 
    }
  ]
}"


echo "Lambda-Trigger hinzugefügt: Uploads in ${IN_BUCKET_NAME} werden automatisch verarbeitet."
echo "Setup abgeschlossen!"
echo "In-Bucket: ${IN_BUCKET_NAME}"
echo "Out-Bucket: ${OUT_BUCKET_NAME}"
