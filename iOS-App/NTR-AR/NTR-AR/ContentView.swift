import SwiftUI

struct ContentView: View {
	 @State private var resultMessage: String = "Press the button to test network call"
	 @State private var isLoading: Bool = false

	 var body: some View {
		  VStack(spacing: 20) {
				Text(resultMessage)
					 .multilineTextAlignment(.center)
					 .padding()

				if isLoading {
					 ProgressView()
						  .progressViewStyle(CircularProgressViewStyle())
				}

				Button(action: {
					 testNetworkCall()
				}) {
					 Text("Test Network Call")
						  .padding()
						  .background(Color.blue)
						  .foregroundColor(.white)
						  .cornerRadius(10)
				}
		  }
		  .padding()
	 }

	 // The function must be defined within the struct scope, not inside the body
	 func testNetworkCall() {
		  isLoading = true
		  resultMessage = "Sending request..."

		  // Replace with your actual bucket name and object key
		  let bucketName = "ntr-ar-room-scans-unique-vdg8fyp4"
		  let objectKey = "example.txt"

		  // Call the networking manager function
		  NetworkingManager.shared.processRoomScan(bucketName: bucketName, objectKey: objectKey) { result in
				DispatchQueue.main.async {
					 isLoading = false
					 switch result {
					 case .success(let response):
						  resultMessage = "Success: \(response)"
					 case .failure(let error):
						  resultMessage = "Error: \(error.localizedDescription)"
					 }
				}
		  }
	 }
}

struct ContentView_Previews: PreviewProvider {
	 static var previews: some View {
		  ContentView()
	 }
}
