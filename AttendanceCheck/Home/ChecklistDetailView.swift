//
//  ChecklistDetailView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ChecklistDetailView: View {
    let eventName: String
    let eventLocation: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(eventName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            Text("위치: \(eventLocation)")
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ChecklistDetailView(eventName: "개회식", eventLocation: "6129", description: "DetailView Test: 개회식 테스트")
}
