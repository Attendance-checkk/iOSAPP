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
