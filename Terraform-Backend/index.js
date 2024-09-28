const AWS = require('aws-sdk');

// instance of S3
const s3 = new AWS.S3();

exports.handler = async (event) => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  try {
    // Fetch bucket name from event or environment variable
    const bucketName = event.bucketName || process.env.BUCKET_NAME;
    const objectKey = event.objectKey;

    // Validate the presence of bucketName and objectKey
    if (!bucketName) {
      throw new Error("Bucket name is missing.");
    }

    if (!objectKey) {
      throw new Error("Object key is missing in the event data.");
    }

    // Fetch the object from S3
    const data = await s3.getObject({
      Bucket: bucketName,
      Key: objectKey,
    }).promise();

    console.log('Object fetched successfully:', data);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Room scan processed successfully!" }),
    };
  } catch (error) {
    console.error("Error processing room scan:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: "Failed to process room scan.", error: error.message }),
    };
  }
};
