import ARKit
import SwiftUI
import RealityKit
import FocusEntity

struct RealityKitView: UIViewRepresentable {
    
    @Binding var furnitureName: String  // Bind the furniture name from ContentView

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
        
        #if DEBUG
        view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
        #endif
        
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
        Coordinator(furnitureName: $furnitureName)  // Pass the binding to the Coordinator
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // No update needed for now
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        @Binding var furnitureName: String
        weak var view: ARView?
        var focusEntity: FocusEntity?
        
        init(furnitureName: Binding<String>) {
            self._furnitureName = furnitureName
        }
        
        @objc func handleTap() {
            guard let view = self.view, !furnitureName.isEmpty else { return }

            // Create an anchor to attach the model to
            let anchor = AnchorEntity(plane: .horizontal)
            view.scene.addAnchor(anchor)
            
            // Load and scale the furniture model
            if let modelEntity = try? ModelEntity.loadModel(named: furnitureName) {
                modelEntity.scale = [0.0003, 0.0003, 0.0003]  // Adjust scaling
                anchor.addChild(modelEntity)
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
    
    @State private var furnitureName = ""  // Use @State for the furniture name
    
    var body: some View {
        VStack {
            
            if furnitureName.isEmpty {
                Text("No furniture selected.")
            } else {
                Text("Furniture Selected: \(furnitureName)")
            }
            
            RealityKitView(furnitureName: $furnitureName)  // Pass the state as a binding
                .ignoresSafeArea()
            
            HStack {
                Button("Add Bed") {
                    furnitureName = "Bed"
                }
                .padding()
                
                Button("Add Dresser") {
                    furnitureName = "Dresser"
                }
                .padding()
                
                Button("Add Desk") {
                    furnitureName = "Computer_Desk"
                }
                .padding()
            }
        }
    }
}
