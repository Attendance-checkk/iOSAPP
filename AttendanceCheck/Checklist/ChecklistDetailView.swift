//
//  ChecklistDetailView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ChecklistDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let eventName: String
    let detailBannerImageName: String
    let eventLocation: String
    let description: String
    let startTime: String
    let endTime: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(detailBannerImageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .background(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke((colorScheme == .light) ? Color.primary : Color.clear, lineWidth: 1)
                )
                .padding(.vertical, 10)
            
            List {
                Section(header: Text("위치")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Text(eventLocation)
                }
                
                Section(header: Text("시간")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Text("시작 | \(startTime)")
                    Text("종료 | \(endTime)")
                }
                
                Section(header: Text("설명")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Text(descriptionParse(description))
                }
            }
        }
        .navigationTitle("상세 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func descriptionParse(_ string: String) -> String {
        return string.replacingOccurrences(of: "|", with: "\n")
    }
}

#Preview {
    ChecklistDetailView(eventName: "개회식", detailBannerImageName: "SWCUAF_EVENT_1", eventLocation: "6129", description: "DetailView Test: 개회식 테스트", startTime: "5일(화) 10:30", endTime: "5일(수) 11:00")
}
