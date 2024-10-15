//
//  MapFullScreenView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/15/24.
//

import SwiftUI

struct MapFullScreenView: View {
    @Binding var isMapFullScreen: Bool
    @Binding var isMapLandscape: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastSclae: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var imageName: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(30)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                .rotationEffect(.degrees(isMapLandscape ? 90 : 0))
                .scaleEffect(scale, anchor: .center)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = CGSize(width: gesture.translation.width + lastOffset.width, height: gesture.translation.height + lastOffset.height)
                        }
                        .onEnded{ _ in
                            lastOffset = offset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged{ value in
                            scale = lastSclae * value.magnitude
                        }
                        .onEnded{ value in
                            lastSclae = scale
                            if scale < 1.0 {
                                scale = 1.0
                                resetToCenter()
                            }
                        }
                )
                .onTapGesture {
                    withAnimation {
                        isMapFullScreen = false
                        isMapLandscape = false
                        resetToCenter()
                    }
                }
        }
        .onAppear {
            withAnimation {
                resetToCenter()
            }
        }
    }
    
    private func resetToCenter() {
        offset = .zero
        lastOffset = .zero
        scale = 1.0
    }
}
