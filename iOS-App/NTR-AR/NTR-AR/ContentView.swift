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
            
            // Load and scale the furniture model
            if let modelEntity = try? ModelEntity.loadModel(named: furnitureName) {
                modelEntity.scale = SIMD3<Float>(Float(entityScaling[0]), Float(entityScaling[1]), Float(entityScaling[2]))
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
	 
	 @State private var furnitureName = ""
	 @State private var entityScaling = [0.0,0.0,0.0]
	 @State private var scaleValue: Float = 1.0
	 
	var body: some View {
			  VStack {
					
					// RealityKitView to display AR content
					RealityKitView(furnitureName: $furnitureName, entityScaling: $entityScaling)  // Pass the state as a binding
						 .ignoresSafeArea()
					
					Spacer()
					
					// Scale slider for adjusting the size of the furniture
					VStack {
						 Text("Adjust Scale: \(scaleValue, specifier: "%.2f")x")
							  .font(.subheadline)
						 Slider(value: $scaleValue, in: 0.5...2.0)
							  .padding()
					}
					.background(Color(.systemGray6))
					.cornerRadius(10)
					.padding([.leading, .trailing, .bottom])
					
					// Furniture picker and place button in a horizontal stack
					HStack {
						 
						 // Furniture Picker
						 Picker(selection: $furnitureName, label: Text("Pick Furniture")) {
							  Text("Bed").tag("Bed")
							  Text("Dresser").tag("Dresser")
							  Text("Desk").tag("Computer_Desk")
						 }
						 .pickerStyle(MenuPickerStyle()) // Use a menu picker style for better visual appearance
						 .padding(.leading)
						 
						 Spacer()
						 
						 // Place button
						 Button("Place") {
							  if !furnitureName.isEmpty {
									entityScaling = [Double(scaleValue), Double(scaleValue), Double(scaleValue)]
							  }
						 }
						 .padding()
						 .background(Color.blue)
						 .foregroundColor(.white)
						 .cornerRadius(10)
						 .padding(.trailing)
					}
					.background(Color(.systemGray6))
					.cornerRadius(10)
					.padding([.leading, .trailing, .bottom])
			  }
			  .background(Color(.systemGray6)) // Background color to make the UI cleaner
		 }
	}
