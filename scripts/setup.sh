#!/bin/bash

# Variablen
BUCKET_IN="csv2json-in-bucket"
BUCKET_OUT="csv2json-out-bucket"
FUNCTION_NAME="CsvToJsonLambda"

# Prüfen ob AWS CLI installiert ist
if ! command -v aws &> /dev/null; then
    echo "AWS CLI ist nicht installiert. Bitte installieren Sie AWS CLI."
    exit 1
fi

# S3 Buckets erstellen
aws s3 mb "s3://$BUCKET_IN"
aws s3 mb "s3://$BUCKET_OUT"

# Lambda-Package erstellen
npm install
tsc
zip -r function.zip .

# Lambda-Funktion erstellen
aws lambda create-function \
    --function-name $FUNCTION_NAME \
    --runtime nodejs18.x \
    --role "<YOUR_AWS_ROLE_ARN>" \
    --handler handler.handler \
    --zip-file fileb://function.zip

# Event-Trigger konfigurieren
aws s3api put-bucket-notification-configuration --bucket $BUCKET_IN \
    --notification-configuration '{
        "LambdaFunctionConfigurations": [
            {
                "LambdaFunctionArn": "<YOUR_LAMBDA_ARN>",
                "Events": ["s3:ObjectCreated:*"]
            }
        ]
    }'

echo "Setup abgeschlossen!"