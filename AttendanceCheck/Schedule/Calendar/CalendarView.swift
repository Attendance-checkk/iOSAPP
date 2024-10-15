//
//  CalendarView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            VStack {
                Text((lastScale == 1.0 && lastOffset == .zero) ? "🔍 이미지를 줌인해보세요" : "👇 돌아가시려면 이미지를 클릭하세요")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 30)
                
                Image("SWCUAFTIMETABLE")
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 5)
                            .cornerRadius(20)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10)
                    .scaleEffect(scale, anchor: .center)
                    .offset(x: offset.width, y: offset.height)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = CGSize(width: gesture.translation.width + lastOffset.width, height: gesture.translation.height + lastOffset.height)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value.magnitude
                            }
                            .onEnded { value in
                                lastScale = scale
                                if scale < 1.0 {
                                    scale = 1.0
                                    resetToCenter()
                                }
                            }
                    )
                    .onTapGesture {
                        withAnimation {
                            resetToCenter()
                        }
                    }
            }
            .padding()
            .onAppear {
                withAnimation {
                    resetToCenter()
                }
            }
        }
    }
    
    private func resetToCenter() {
        offset = .zero
        lastOffset = .zero
        scale = 1.0
        lastScale = 1.0
    }
}

#Preview {
    CalendarView()
}
