//
//  MapView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapView: View {
    @State private var isMapFullScreen: Bool = false
    @State private var isMapLandscape: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !isMapFullScreen {
                    VStack {
                        Text("👇 이미지를 클릭하세요!")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.bottom, 30)
                        
                        Image("SWCUAFFIRSTFLOOR")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primary, lineWidth: 5)
                                    .cornerRadius(20)
                            )
                            .onTapGesture {
                                withAnimation {
                                    isMapFullScreen = true
                                    isMapLandscape = true
                                }
                            }
                    }
                    .padding()
                }
                
                if isMapFullScreen {
                    MapFullScreenView(isMapFullScreen: $isMapFullScreen, isMapLandscape: $isMapLandscape, imageName: "SWCUAFFIRSTFLOOR")
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .navigationTitle("지도")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapView()
}
