import * as AWS from 'aws-sdk';
import * as csv from 'csvtojson';

const s3 = new AWS.S3();

export const handler = async (event: any): Promise<void> => {
    try {
        const inputBucket = process.env.INPUT_BUCKET;
        const outputBucket = process.env.OUTPUT_BUCKET;
        const outputFileKeyPrefix = process.env.OUTPUT_FILE_PREFIX || 'converted';

        if (!inputBucket || !outputBucket) {
            throw new Error('INPUT_BUCKET and OUTPUT_BUCKET environment variables must be set.');
        }

        const record = event.Records[0];
        const inputKey = record.s3.object.key;

        console.log(`Processing file from bucket: ${inputBucket}, key: ${inputKey}`);

        // Fetch the CSV file from the input bucket
        const csvData = await s3
            .getObject({
                Bucket: inputBucket,
                Key: inputKey,
            })
            .promise();

        if (!csvData.Body) {
            throw new Error('The fetched file has no content.');
        }

        const csvContent = csvData.Body.toString('utf-8');
        console.log(`Fetched CSV content (truncated to 500 characters):\n${csvContent.slice(0, 500)}...`);

        // Detect the delimiter (comma or semicolon)
        const commaCount = (csvContent.match(/,/g) || []).length;
        const semicolonCount = (csvContent.match(/;/g) || []).length;
        const delimiter = commaCount >= semicolonCount ? ',' : ';';

        console.log(`Detected delimiter: '${delimiter}'`);

        // Convert CSV to JSON
        const jsonArray = await csv({ delimiter }).fromString(csvContent);

        console.log(`Converted JSON structure:`, jsonArray);

        const outputKey = `${outputFileKeyPrefix}/${inputKey.replace(/\.csv$/i, '.json')}`;

        // Upload the JSON file to the output bucket
        await s3
            .putObject({
                Bucket: outputBucket,
                Key: outputKey,
                Body: JSON.stringify(jsonArray, null, 2),
                ContentType: 'application/json',
            })
            .promise();

        console.log(`Successfully converted and uploaded JSON to bucket: ${outputBucket}, key: ${outputKey}`);
    } catch (err) {
        console.error('An error occurred:', err);
        throw err;
    }
};
