import { S3 } from 'aws-sdk';
import { Context, S3Event } from 'aws-lambda';

export const lambdaHandler = async (event: S3Event, context: Context): Promise<void> => {
    const s3 = new S3();

    // Input bucket and key from event
    const inBucket = event.Records[0].s3.bucket.name;
    const inKey = event.Records[0].s3.object.key;

    // Output bucket from environment variables
    const outBucket = process.env.OUTPUT_BUCKET;
    if (!outBucket) {
        console.error("OUTPUT_BUCKET environment variable is not set.");
        return;
    }

    const outKey = inKey.replace(/\\.csv$/, '.json');

    try {
        // Download the CSV file
        const response = await s3.getObject({ Bucket: inBucket, Key: inKey }).promise();

        if (!response.Body) {
            throw new Error("The S3 object body is empty.");
        }

        const content = response.Body.toString('utf-8');

        // Parse CSV to JSON
        const rows = content.split('\\n');
        const headers = rows[0].split(',');
        const jsonData = rows.slice(1).filter(row => row.trim() !== '').map(row => {
            const values = row.split(',');
            return headers.reduce((acc, header, index) => {
                acc[header.trim()] = values[index].trim();
                return acc;
            }, {} as Record<string, string>);
        });

        // Convert JSON to string
        const jsonString = JSON.stringify(jsonData);

        // Upload the JSON file
        await s3.putObject({
            Bucket: outBucket,
            Key: outKey,
            Body: jsonString,
            ContentType: 'application/json',
        }).promise();

        console.log(`CSV ${inKey} converted to JSON and uploaded to ${outBucket}/${outKey}`);
    } catch (error) {
        console.error(`Error processing file ${inKey} from bucket ${inBucket}:`, error);
    }
};
