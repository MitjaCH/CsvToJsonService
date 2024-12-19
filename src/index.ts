import { S3 } from 'aws-sdk';
import { Context, S3Event } from 'aws-lambda';

export const lambdaHandler = async (event: S3Event, context: Context): Promise<void> => {
    const s3 = new S3();

    const inBucket = event.Records[0].s3.bucket.name;
    const inKey = decodeURIComponent(event.Records[0].s3.object.key);
    const outBucket = process.env.OUTPUT_BUCKET;

    if (!outBucket) {
        console.error("OUTPUT_BUCKET environment variable is not set.");
        return;
    }

    const outKey = inKey.replace(/\\.csv$/, '.json');

    try {
        const response = await s3.getObject({ Bucket: inBucket, Key: inKey }).promise();

        if (!response.Body) {
            throw new Error("The S3 object body is empty.");
        }

        const content = response.Body.toString('utf-8');
        const rows = content.trim().split('\n');

        if (rows.length < 2) {
            throw new Error("The CSV file contains no data rows.");
        }

        const headers = rows[0].split(',').map(h => h.trim());
        const jsonData = rows.slice(1)
            .filter(row => row.trim() !== '')
            .map(row => {
                const values = row.split(',');
                return headers.reduce((acc, header, index) => {
                    acc[header] = values[index]?.trim() || null;
                    return acc;
                }, {} as Record<string, string | null>);
            });

        if (jsonData.length === 0) {
            throw new Error("The CSV file was parsed but contains no valid data.");
        }

        const jsonString = JSON.stringify(jsonData, null, 2);

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
