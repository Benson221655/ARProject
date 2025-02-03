//
//  ContentView.swift
//  TestAR
//
//  Created by Benson Hsu on 1/26/25.
//

import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    @State var distance: Float = 0
    @State var positions: [SIMD3<Float>] = []

    var body: some View {
        VStack {
            ARViewContainer(distance: $distance, positions: $positions)
            Text("Distance: \(distance, specifier: "%.2f") inches")
                .foregroundColor(.white)
                .font(.headline)
                .padding(.bottom, 100)
        }.edgesIgnoringSafeArea(.all)
    }
}
