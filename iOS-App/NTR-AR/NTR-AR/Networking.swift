//
//  Networking.swift
//  NTR-AR
//
//  Created by Nafees-ul Haque on 9/28/24.
//

import Foundation

// Enum for API-related constants
enum APIConstants {
	 static let baseURL = "https://6fedvi50i4.execute-api.us-east-1.amazonaws.com/dev" // Base URL for the API Gateway
	 static let scanEndpoint = "/scan" // Endpoint for the room scan
}

// Enum for networking errors
enum NetworkingError: Error, LocalizedError {
	 case invalidURL
	 case invalidResponse
	 case failedRequest(String)
	 case decodingError
	 
	 var errorDescription: String? {
		  switch self {
		  case .invalidURL:
				return "Invalid URL"
		  case .invalidResponse:
				return "Invalid Response from Server"
		  case .failedRequest(let message):
				return "Request failed with error: \(message)"
		  case .decodingError:
				return "Failed to decode the response"
		  }
	 }
}

// Networking class for making API calls
class NetworkingManager {
	 static let shared = NetworkingManager()
	 
	 private init() {}
	 
	 // POST request to process room scan
	 func processRoomScan(bucketName: String, objectKey: String, completion: @escaping (Result<Data, NetworkingError>) -> Void) {
		  // Construct the full URL using the base URL and endpoint
		  guard let url = URL(string: APIConstants.baseURL + APIConstants.scanEndpoint) else {
				completion(.failure(.invalidURL))
				return
		  }
		  
		  // Define the request body with bucket name and object key
		  let requestBody: [String: Any] = [
				"bucketName": bucketName,
				"objectKey": objectKey
		  ]

		  // Convert the request body to JSON data
		  guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else {
				completion(.failure(.invalidResponse))
				return
		  }

		  // Create the URLRequest with the correct HTTP method and headers
		  var request = URLRequest(url: url)
		  request.httpMethod = "POST"
		  request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		  request.httpBody = httpBody

		  // Start the network request using URLSession
		  URLSession.shared.dataTask(with: request) { data, response, error in
				// Check if there's an error in the request
				if let error = error {
					 completion(.failure(.failedRequest(error.localizedDescription)))
					 return
				}
				
				// Validate the response, ensuring it falls within the expected range
				guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
					 completion(.failure(.invalidResponse))
					 return
				}
		  
				// Parse the response data to a string format
//				guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
//					 completion(.failure(.decodingError))
//					 return
//				}
				
				// Return the successful response
              completion(.success(data!))
		  }.resume() // Ensure the task resumes immediately
	 }
}
