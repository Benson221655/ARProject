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
        var dotLocations = [simd_float3]()
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let arView = gestureRecognizer.view as? ARView else { return }
            let tapLocation = gestureRecognizer.location(in: arView)
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            if let firstResult = results.first {
                var location = simd_make_float3(firstResult.worldTransform.columns.3)
                if dotLocations.count % 2 == 1 {
                    let connectionAnchor = connectDots(position1: dotLocations[dotLocations.count - 1], position2: location)
                    arView.scene.addAnchor(connectionAnchor)
                }
                else {
                    dotLocations.append(location)
                }
                location.y += 0.025
                let sphere = createSphere()
                let objectAnchor = AnchorEntity(world: location)
                objectAnchor.addChild(sphere)
                arView.scene.addAnchor(objectAnchor)
            }
        }
        
        func createSphere() -> ModelEntity {
            let sphere = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .red, isMetallic: false)
            let entity = ModelEntity(mesh: sphere, materials: [material])
            return entity
        }
        
        func connectDots(position1: simd_float3, position2: simd_float3) -> AnchorEntity {
            let midPosition = SIMD3(x:(position1.x + position2.x) / 2, y:(position1.y + position2.y) / 2, z:(position1.z + position2.z) / 2)
                
            let anchor = AnchorEntity()
            anchor.position = midPosition
            anchor.look(at: position1, from: midPosition, relativeTo: nil)
            
            let meters = simd_distance(position1, position2)
            
            let lineMaterial = SimpleMaterial.init(color: .red, roughness: 1, isMetallic: false)
            
            let bottomLineMesh = MeshResource.generateBox(width:0.025, height: 0.025/2.5, depth: meters)
            
            let bottomLineEntity = ModelEntity(mesh: bottomLineMesh, materials: [lineMaterial])
            
            bottomLineEntity.position = .init(0, 0.025, 0)
            anchor.addChild(bottomLineEntity)
            
            return anchor
        }
    }
}
