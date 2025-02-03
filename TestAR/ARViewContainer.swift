//
//  ARViewContainer.swift
//  TestAR
//
//  Created by Benson Hsu on 1/26/25.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @Binding var distance: Float
    @Binding var positions: [SIMD3<Float>]
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(distance: $distance, positions: $positions)
    }
}

class Coordinator: NSObject {
    @Binding var distance: Float
    @Binding var positions: [SIMD3<Float>]
    
    init(distance: Binding<Float>, positions: Binding<[SIMD3<Float>]>) {
        _distance = distance
        _positions = positions
    }

    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let arView = gestureRecognizer.view as? ARView else { return }
        let tapLocation = gestureRecognizer.location(in: arView)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any)
        if let firstResult = results.first {
            let location = simd_make_float3(firstResult.worldTransform.columns.3)
            if positions.count % 2 == 1 {
                let connectionAnchor = connectDots(position1: positions[positions.count - 1], position2: location)
                distance = calculateDist(position1: positions[positions.count - 1], position2: location)
                arView.scene.addAnchor(connectionAnchor)
            }
            positions.append(location)
            let sphere = createSphere()
            let objectAnchor = AnchorEntity(world: location)
            objectAnchor.addChild(sphere)
            arView.scene.addAnchor(objectAnchor)
        }
    }
    
    func createSphere() -> ModelEntity {
        let sphere = MeshResource.generateSphere(radius: 0.0025)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: sphere, materials: [material])
        return entity
    }
    
    func connectDots(position1: simd_float3, position2: simd_float3) -> AnchorEntity {
        let midPosition = SIMD3(x: (position1.x + position2.x) / 2, y: (position1.y + position2.y) / 2, z: (position1.z + position2.z) / 2)
        let connectionAnchor = AnchorEntity()
        connectionAnchor.position = midPosition
        connectionAnchor.look(at: position1, from: midPosition, relativeTo: nil)
        let meters = simd_distance(position1, position2)
        let connectionMaterial = SimpleMaterial(color: .red, roughness: 1, isMetallic: false)
        let connectionMesh = MeshResource.generateBox(width: 0.00175, height: 0.00175 / 4, depth: meters)
        let connectionEntity = ModelEntity(mesh: connectionMesh, materials: [connectionMaterial])
        connectionEntity.position = .init(0, 0, 0)
        connectionAnchor.addChild(connectionEntity)
        
        return connectionAnchor
    }
    
    func calculateDist(position1: simd_float3, position2: simd_float3) -> Float {
        let xDist = position2.x - position1.x
        let yDist = position2.y - position1.y
        let zDist = position2.z - position1.z
        let distance = sqrt(xDist * xDist + yDist * yDist + zDist * zDist)
        return distance * 39.370
    }
}
