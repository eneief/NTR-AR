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

            var scale = [0.0,0.0,0.0]
            if(furnitureName == "Asylum_Bed"){
                scale = [0.003, 0.003, 0.003]
            }
            if(furnitureName == "Dresser"){
                scale = [0.008, 0.008, 0.008]
            }
            if(furnitureName == "Computer_Desk"){
                scale = [0.006, 0.006, 0.006]
            }

            if let modelEntity = try? ModelEntity.loadModel(named: furnitureName) {
                modelEntity.scale = SIMD3<Float>(Float(scale[0]), Float(scale[1]), Float(scale[2]))
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
	 @State private var entityScaling = [0.0, 0.0, 0.0]
	 
	 var body: some View {
		  ZStack {
				GrainyGradientView()
					 .ignoresSafeArea()
				
				VStack {
					 
					 RealityKitView(furnitureName: $furnitureName, entityScaling: $entityScaling)
						  .ignoresSafeArea()
					 
					 Spacer()
					 
					 HStack {
						  // Furniture Picker segmented
						  Picker(selection: $furnitureName, label: Text("Select Furniture")) {
								Text("Bed").tag("Bed")
								Text("Dresser").tag("Dresser")
								Text("Desk").tag("Computer_Desk")
						  }
						  .pickerStyle(.segmented)
						  .padding()
					 }
					 .background(Color.white.opacity(0.9))
					 .cornerRadius(20)
					 .shadow(radius: 5)
					 .padding([.leading, .trailing, .bottom], 10)
				}
		  }
	 }
}


struct GrainyGradientView: View {
	 var body: some View {
		  GeometryReader { geometry in
				ZStack {
					 AngularGradient(gradient: Gradient(colors: [.indigo, .purple, .blue, .indigo]), center: .center)
					 
					 Color.black.opacity(0.1)
						  .blendMode(.overlay)
					 
					 NoiseView()
						  .opacity(0.05)
						  .blendMode(.overlay)
				}
		  }
	 }
}

struct NoiseView: View {
	 @State private var noiseImage: UIImage?
	 
	 var body: some View {
		  Image(uiImage: noiseImage ?? UIImage())
				.resizable()
				.onAppear {
					 self.noiseImage = generateNoiseImage()
				}
	 }
	 
	 func generateNoiseImage() -> UIImage {
		  let size = CGSize(width: 300, height: 300)
		  let renderer = UIGraphicsImageRenderer(size: size)
		  
		  let image = renderer.image { context in
				for _ in 0..<Int(size.width * size.height) {
					 let randomX = CGFloat.random(in: 0..<size.width)
					 let randomY = CGFloat.random(in: 0..<size.height)
					 let randomGray = CGFloat.random(in: 0...1)
					 
					 UIColor(white: randomGray, alpha: 1).setFill()
					 context.fill(CGRect(x: randomX, y: randomY, width: 1, height: 1))
				}
		  }
		  return image
	 }
}
