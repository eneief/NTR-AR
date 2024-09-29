//
//  ContentView.swift
//  NTR-AR
//
//  Created by Nafees-ul Haque on 9/28/24.
//

import ARKit
import SwiftUI
import RealityKit
import FocusEntity

var furnitureName = ""


struct RealityKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView()
        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        view.addSubview(coachingOverlay)
        #if DEBUG
        view.debugOptions = [.showFeaturePoints, .showAnchorOrigins, .showAnchorGeometry]
        #endif
        
        context.coordinator.view = view
        session.delegate = context.coordinator
        
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )
        
        return view
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var focusEntity: FocusEntity?
        
        @objc func handleTap() {
            if(furnitureName == ""){
                return
            }
            guard let view = self.view, let focusEntity = self.focusEntity else { return }

            // Create a new anchor to add content to
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)

            // Add a Box entity with a blue material
            let furniture = try! ModelEntity.loadModel(named: furnitureName)
            furniture.scale = [0.0003, 0.0003, 0.0003]
            furniture.position = furniture.position

            anchor.addChild(furniture)
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = self.view else { return }
            debugPrint("Anchors added to the scene: ", anchors)
            self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
        }
    }
    
    func updateUIView(_ view: ARView, context: Context) {
    }
}

struct ContentView : View {

    var body: some View {
        VStack(){
            RealityKitView()
                .ignoresSafeArea()
            
            HStack(){
                Button(
                    "Add Bed",
                    action:{
                        furnitureName = "Bed"
                    }
                
                )
                
                Button(
                    "Add Dresser",
                    action:{
                        furnitureName = "Dresser"
                    }
                
                )
                
                Button(
                    "Add Desk",
                    action:{
                        furnitureName = "Computer_Desk"
                    }
                
                )
            }
            
        }
        
    }
}
#Preview {
    ContentView()
}
