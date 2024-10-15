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
        if eventManager.isLoading {
            ProcessingView(messageString: "정보를 가져오는 중입니다..")
                .transition(.opacity)
                .ignoresSafeArea(.all)
        } else {
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
                    
                    if let events = eventManager.programs {
                        List(events, id: \.event_code) { event in
                            NavigationLink(destination: detailView(for: event)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        
                                        Text("\(String(describing: event.event_start_time ?? "")) ~ \(event.event_end_time ?? "")")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Text(event.event_name)
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
                                                .opacity(eventManager.isEventCompleted(code: event.event_code) ? 1.0 : 0.0)
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
    }
    
    private func detailView(for event: Events) -> some View {
        let title: String = event.event_name
        let location: String = event.location
        let description: String = event.description
        let startTime: String = event.event_start_time ?? "EVENTSTARTTIMEERROR"
        let endTime: String = event.event_end_time ?? "EVENTENDTIMEERROR"
        
        return ChecklistDetailView(eventName: title, eventLocation: location, description: description, startTime: startTime, endTime: endTime)
    }
    
    private func changeProgressTitle() -> String {
        return eventManager.progress == 1.0 ? "🥳 스탬프 모으기 완료!" : "학술제 참여하고 경품 받자!"
    }
}

#Preview {
    ChecklistView()
}
