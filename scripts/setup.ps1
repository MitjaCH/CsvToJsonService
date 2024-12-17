# Variablen
$bucketIn = "csv2json-in-bucket"
$bucketOut = "csv2json-out-bucket"
$functionName = "CsvToJsonLambda"

# AWS CLI Installation prüfen
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Error "AWS CLI nicht installiert!"
    exit 1
}

# S3 Buckets erstellen
aws s3 mb "s3://$bucketIn"
aws s3 mb "s3://$bucketOut"

# Lambda-Package erstellen
npm install
tsc
zip -r function.zip .

# Lambda-Funktion erstellen
aws lambda create-function `
    --function-name $functionName `
    --runtime nodejs18.x `
    --role CsvToJsonLambdaExecutionRole `
    --handler handler.handler `
    --zip-file fileb://function.zip

# Event-Trigger für S3 In-Bucket konfigurieren
awsaws s3api put-bucket-notification-configuration --bucket $bucketIn `
--notification-configuration "{
    \"LambdaFunctionConfigurations\": [
        {
            \"LambdaFunctionArn\": \"CsvToJsonLambdaFunction\",
            \"Events\": [\"s3:ObjectCreated:*\"] 
        }
    ]
}"

Write-Host "Setup abgeschlossen!"