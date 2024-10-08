// Import AWS SDK
// import {S3Client} from '@aws-sdk/client-s3';
const AWS = require("@aws-sdk/client-s3")
// Create an instance of S3
// const s3 = new S3Client();
const s3 = new AWS.S3();

exports.handler = async (event) => {
  console.log()
  console.log("Received event:", JSON.stringify(event, null, 2)); // Log the incoming event
  event = JSON.parse(event.body)
  try {
    // Extract bucket name from event or fallback to environment variable
    const bucketName = event.bucketName || process.env.BUCKET_NAME;
    const objectKey = event.objectKey;

    // Validate required parameters
    if (!bucketName) {
      console.error("Error: Missing bucket name.");
      // throw new Error("Bucket name is missing.");
      return {
        statusCode: 500,
        body: JSON.stringify({
          message: "Missing bucket name" + JSON.stringify(event),
        }),
      };
    }

    if (!objectKey) {
      console.error("Error: Missing object key.");
      // throw new Error("Object key is missing in the event data.");
      return {
        statusCode: 500,
        body: JSON.stringify({
          message: "Missing object key" + JSON.stringify(event),
        }),
      };
    }

    // Fetch the object from S3
    const params = {
      Bucket: bucketName,
      Key: objectKey,
    };

    console.log(`Fetching object from S3 - Bucket: ${bucketName}, Key: ${objectKey}`);

    const command = new AWS.GetObjectCommand({
      Bucket: bucketName,
      Key: objectKey,
    });

    try {
      const response = await s3.send(command);
      // The Body object also has 'transformToByteArray' and 'transformToWebStream' methods.
      const str = await response.Body.transformToString();
      console.log(str);
      return {
        statusCode: 200,
        body: str, // Optionally include data
      };
    } catch (err) {
      console.error(err);
    }

    const data = await s3.getObject(params).promise();

    // Log the content of the fetched object for debugging
    console.log('Object fetched successfully:', data);

    // You can add custom processing logic here if needed (e.g., parsing, analysis)

    // Return a success response


  } catch (error) {

    // Return a failure response with error details
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: "Failed to process room scan.",
        error: error.message,
      }),
    };
  }
};
