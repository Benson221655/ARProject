//
//  ARViewContainer.swift
//  TestAR
//
//  Created by Benson Hsu on 1/26/25.
//

import SwiftUI
import ARKit
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        
       var parent: ARViewContainer
       
       init(_ parent: ARViewContainer) {
           self.parent = parent
       }

       @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
           guard let arView = gestureRecognizer.view as? ARView else { return }
           let tapLocation = gestureRecognizer.location(in: arView)
           let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
           if let firstResult = results.first {
               var location = simd_make_float3(firstResult.worldTransform.columns.3)
               location.y += 0.025
               let sphere = createSphere()
               let objectAnchor = AnchorEntity(world: location)
               objectAnchor.addChild(sphere)
               arView.scene.addAnchor(objectAnchor)
           }
       }
        
        func createSphere() -> ModelEntity {
            let sphere = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .red, isMetallic: true)
            let entity = ModelEntity(mesh: sphere, materials: [material])
            return entity
        }
    }
}
