//
//  MapView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isMapFullScreen: Bool = false
    @State private var isMapLandscape: Bool = false
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let locations = campusLocations
    
    var body: some View {
        NavigationStack {
            VStack {
                Text((scale != 1.0 || offset != .zero) ? "👇 돌아가시려면 이미지를 눌러주세요" : "🔍 이미지를 확대해보세요")
                
                GeometryReader { geometry in
                    Image("SCHUCampusMap")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((colorScheme == .light) ? Color.primary : Color.clear, lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                        .padding()
                        .scaleEffect(scale, anchor: .center)
                        .offset(x: offset.width, y: offset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    let newOffset = CGSize(width: gesture.translation.width + lastOffset.width, height: 0)
                                    
                                    if isWithinBounds(offset: newOffset, geometry: geometry.size) {
                                        offset = newOffset
                                    }
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value.magnitude
                                    
                                    if newScale >= 1.0 && newScale <= 1.7 {
                                        withAnimation {
                                            scale = newScale
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    print(lastScale)
                                    if scale < 1.0 {
                                        resetToCenter()
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            if scale > 1.0 {
                                withAnimation {
                                    resetToCenter()
                                }
                            } else {
                                withAnimation {
                                    scaleImage()
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                resetToCenter()
                            }
                        }
                        .onDisappear {
                            withAnimation {
                                resetToCenter()
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                
                //            ZStack {
                //                if !isMapFullScreen {
                //                    VStack {
                //                        Text("👇 이미지를 클릭하세요!")
                //                            .font(.title3)
                //                            .fontWeight(.bold)
                //                            .foregroundColor(.primary)
                //                            .padding(.bottom, 30)
                //
                //                        Image("SWCUAFFIRSTFLOOR")
                //                            .resizable()
                //                            .scaledToFit()
                //                            .cornerRadius(20)
                //                            .overlay(
                //                                RoundedRectangle(cornerRadius: 20)
                //                                    .stroke(Color.primary, lineWidth: 5)
                //                                    .cornerRadius(20)
                //                            )
                //                            .onTapGesture {
                //                                withAnimation {
                //                                    isMapFullScreen = true
                //                                    isMapLandscape = true
                //                                }
                //                            }
                //                    }
                //                    .padding()
                //                }
                //
                //                if isMapFullScreen {
                //                    MapFullScreenView(isMapFullScreen: $isMapFullScreen, isMapLandscape: $isMapLandscape, imageName: "SWCUAFFIRSTFLOOR")
                //                        .transition(.scale)
                //                        .zIndex(1)
                //                }
                //            }
                //            .navigationTitle("지도")
                //            .navigationBarTitleDisplayMode(.inline)
                //        }
            }
            
            .navigationTitle("지도")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func scaleImage() {
        offset = .zero
        lastOffset = .zero
        scale = 1.7
        lastScale = 1.7
    }
    
    private func resetToCenter() {
        offset = .zero
        lastOffset = .zero
        scale = 1.0
        lastScale = 1.0
    }
    
    private func isWithinBounds(offset: CGSize, geometry: CGSize) -> Bool {
        let imageSize = CGSize(width: geometry.width * scale, height: geometry.height * scale)
        let imageRect = CGRect(origin: CGPoint(x: offset.width, y: 0), size: imageSize)
        if scale >= 1.4 {
            return imageRect.minX <= geometry.width * 0.6 && imageRect.maxX >= geometry.width
        } else {
            return imageRect.minX >= 0 && imageRect.maxX <= geometry.width
        }
    }
}

#Preview {
    MapView()
}
