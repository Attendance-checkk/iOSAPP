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
    let startTime: String
    let endTime: String
    
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
            
            Text("시간: \(startTime) ~ \(endTime)")
                .font(.title3)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            HStack {
                Text(descriptionParse(description))
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
    
    private func descriptionParse(_ string: String) -> String {
        return string.replacingOccurrences(of: "|", with: "\n")
    }
}

#Preview {
    ChecklistDetailView(eventName: "개회식", eventLocation: "6129", description: "DetailView Test: 개회식 테스트", startTime: "5일(화) 10:30", endTime: "5일(수) 11:00")
}
