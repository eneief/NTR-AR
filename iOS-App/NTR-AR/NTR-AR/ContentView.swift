import ARKit
import SwiftUI
import RealityKit
import FocusEntity

struct RealityKitView: UIViewRepresentable {
    
    @Binding var furnitureName: String
    @Binding var entityScaling: [Double]

    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero)
        
        // AR session configuration
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        // AR coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(coachingOverlay)
        
        context.coordinator.view = view
        session.delegate = context.coordinator
        
        // Tap gesture for placing furniture
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap)
        )
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(furnitureName: $furnitureName, entityScaling: $entityScaling)
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // No update needed for now
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        @Binding var furnitureName: String
        @Binding var entityScaling: [Double]
        
        weak var view: ARView?
        var focusEntity: FocusEntity?
        
        init(furnitureName: Binding<String>, entityScaling: Binding<[Double]>) {
            self._furnitureName = furnitureName
            self._entityScaling = entityScaling
        }
        
        @objc func handleTap() {
            guard let view = self.view, !furnitureName.isEmpty else { return }

            // Create an anchor to attach the model to
            let anchor = AnchorEntity(plane: .horizontal)
            view.scene.addAnchor(anchor)
            
//             Load and scale the furniture model
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("Could not find documents directory")
                    return
                }

//                 Create a file URL directly in the documents direc"tory
            let url = documentsDirectory.appendingPathComponent(furnitureName+".usdz")
            
                    
            do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    if let fileSize = attributes[FileAttributeKey.size] as? NSNumber {
                        print("File size: \(fileSize.intValue) bytes")
                    } else {
                        print("Could not retrieve file size.")
                    }
                } catch {
                    print("Error retrieving file attributes: \(error.localizedDescription)")
                }


            if let modelEntity = try? ModelEntity.loadModel(named: furnitureName) {
                modelEntity.scale = SIMD3<Float>(Float(entityScaling[0]), Float(entityScaling[1]), Float(entityScaling[2]))
                anchor.addChild(modelEntity)
                print("Successfully loaded: \(furnitureName)")
            } else {
                print("Error: Unable to load model for \(furnitureName)")
            }
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // Focus entity initialization
            guard let view = self.view else { return }
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
        }
    }
}

struct ContentView: View {
    
    @State private var furnitureName = ""
    @State private var entityScaling = [0.0,0.0,0.0]
    
    @State private var isLoading: Bool = true
    
    init(){
        
        let bucketName = "ntr-ar-room-scans-unique-vdg8fyp4"
        let objectKey = ["Asylum_Bed.usdz", "Computer_Desk.usdz", "Dresser.usdz"]
        
        for file in objectKey {
            // Call the networking manager function
            NetworkingManager.shared.processRoomScan(bucketName: bucketName, objectKey: file) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        
                        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                            print("Could not find documents directory")
                            return
                        }

                        // Create a file URL directly in the documents directory
                        let fileURL = documentsDirectory.appendingPathComponent(file)

                        do {
                            // Write the data to the file
                            try response.write(to: fileURL, options: .atomic) // Use .atomic to ensure file integrity
                            print("File saved successfully: \(file)")
                        } catch {
                            print("Error saving file: \(error.localizedDescription)")
                        }
                        
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if furnitureName.isEmpty {
                Text("No furniture selected.")
            } else {
                Text("Furniture Selected: \(furnitureName)")
            }
            
            RealityKitView(furnitureName: $furnitureName, entityScaling: $entityScaling)  // Pass the state as a binding
                .ignoresSafeArea()
            
            HStack {
                Button("Add Bed") {
                    furnitureName = "Asylum_Bed"
                    entityScaling = [0.003, 0.003, 0.003]
                }
                .padding()
                
                Button("Add Dresser") {
                    furnitureName = "Dresser"
                    entityScaling = [0.008, 0.008, 0.008]
                }
                .padding()
                
                Button("Add Desk") {
                    furnitureName = "Computer_Desk"
                    entityScaling = [0.006, 0.006, 0.006]
                }
                .padding()
            }
        }
    }
}
