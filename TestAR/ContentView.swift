//
//  ContentView.swift
//  TestAR
//
//  Created by Benson Hsu on 1/26/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView : View {
    @State private var arView: ARView?

    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}
