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
            GeometryReader { geometry in
                VStack {
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
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: geometry.size.width, height: 60)
                        
                        Text("위치\n\(eventLocation)")
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary, lineWidth: 1)
                            .frame(width: geometry.size.width, height: 60)
                        
                        Text("시간\n\(startTime) ~ \(endTime)")
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack {
                        Text(descriptionParse(description))
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 20)
                    
                }
            }
        }
        .padding(25)
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
