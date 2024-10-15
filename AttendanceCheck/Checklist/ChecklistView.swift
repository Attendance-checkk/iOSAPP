//
//  ChecklistView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ChecklistView: View {
//    @State private var progress: Double = 0.0
    @EnvironmentObject private var eventManager: EventManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(changeProgressTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                ProgressView(value: eventManager.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 20)
                
                if let events = eventManager.programs?.events {
                    List(events.indices, id: \.self) { index in
                        NavigationLink(destination: detailView(for: index)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    
                                    Text("\(eventManager.programs?.events[index].eventStartTime ?? "") ~ \(eventManager.programs?.events[index].eventEndTime ?? "")")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(events[index].eventName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                GeometryReader { geometry in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: geometry.size.height, height: geometry.size.height)
                                            .foregroundColor(.white)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.black, lineWidth: 1)
                                            }
                                        
                                        Image("SCHUCSTAMP")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.height * 0.9, height: geometry.size.height * 0.9)
                                            .opacity(eventManager.isEventCompleted (index: index) ? 1.0 : 0.0)
                                    }
                                }
                                .frame(width: 50, height: 50)
                            }
                            .padding(.vertical, 10)
                        }
                        
                    }
                }
            }
            .navigationTitle("체크리스트")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func detailView(for index: Int) -> some View {
        let title: String = eventManager.programs?.events[index].eventName ?? "TitleStringError"
        let location: String = eventManager.programs?.events[index].location ?? "LocationStringError"
        let description: String = eventManager.programs?.events[index].descriptionString ?? "DescriptionStringError"
        let startTime: String = eventManager.programs?.events[index].eventStartTime ?? "StartTimeStringError"
        let endTime: String = eventManager.programs?.events[index].eventEndTime ?? "EndTimeStringError"
        
        return ChecklistDetailView(eventName: title, eventLocation: location, description: description, startTime: startTime, endTime: endTime)
    }
    
    private func changeProgressTitle() -> String {
        return eventManager.progress == 1.0 ? "🥳 스탬프 모으기 완료!" : "학술제 참여하고 경품 받자!"
    }
}

#Preview {
    ChecklistView()
}
