// Import AWS SDK
const AWS = require('aws-sdk');

// Create an instance of S3
const s3 = new AWS.S3();

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2)); // Log the incoming event

  try {
    // Extract bucket name from event or fallback to environment variable
    const bucketName = event.bucketName || process.env.BUCKET_NAME;
    const objectKey = event.objectKey;

    // Validate required parameters
    if (!bucketName) {
      console.error("Error: Missing bucket name.");
      throw new Error("Bucket name is missing.");
    }

    if (!objectKey) {
      console.error("Error: Missing object key.");
      throw new Error("Object key is missing in the event data.");
    }

    // Fetch the object from S3
    const params = {
      Bucket: bucketName,
      Key: objectKey,
    };

    console.log(`Fetching object from S3 - Bucket: ${bucketName}, Key: ${objectKey}`);

    const data = await s3.getObject(params).promise();

    // Log the content of the fetched object for debugging
    console.log('Object fetched successfully:', data);

    // You can add custom processing logic here if needed (e.g., parsing, analysis)

    // Return a success response
    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Room scan processed successfully!", data: data }), // Optionally include data
    };

  } catch (error) {
    // Log the error stack trace for debugging
    console.error("Error processing room scan:", error);

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
