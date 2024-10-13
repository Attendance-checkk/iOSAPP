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
                                    
                                    Text("Hello")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(events[index].title)
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
                            .onAppear {
                                print("ChecklistView - VStack - \(index)")
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle("체크리스트")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func detailView(for index: Int) -> some View {
        let title: String = eventManager.programs?.events[index].title ?? "TitleStringError"
        let location: String = eventManager.programs?.events[index].location ?? "LocationStringError"
        let description: String = eventManager.programs?.events[index].descriptionString ?? "DescriptionStringError"
        
        return ChecklistDetailView(eventName: title, eventLocation: location, description: description)
    }
    
    private func changeProgressTitle() -> String {
        return eventManager.progress == 1.0 ? "🥳 스탬프 모으기 완료!" : "학술제 참여하고 경품 받자!"
    }
    
    private func calculateProgress() {
        var newProgress: Double = 0.0
        
        let completedSet = Set(eventManager.completedEvents.split(separator: ",").compactMap{ Int($0) })
        
        if completedSet.contains(0) { newProgress += 0.2 }
        if completedSet.contains(1) { newProgress += 0.2 }
        if completedSet.contains(2...6) { newProgress += 0.2 }
        if completedSet.contains(7) { newProgress += 0.2 }
        if completedSet.contains(8) { newProgress += 0.2 }
        
        eventManager.progress = newProgress
    }
    
    private func completeEvent(index: Int) {
        var completedSet = Set(eventManager.completedEvents.split(separator: ",").compactMap { Int($0) })
        
        if !completedSet.contains(index) {
            completedSet.insert(index)
            eventManager.completedEvents = completedSet.map { String($0) }.joined(separator: ",")
            
            calculateProgress()
        }
    }
    
    // If correct QR code scanned from QRView, then run this function
    public func completeEventByQR(_ qrcode:  String) {
        guard let events = eventManager.programs?.events else { return }
        
        if let matchingEvent = events.first(where: { $0.qrString == qrcode }) {
            print("Matched qrcode: \(qrcode)")
            completeEvent(index: matchingEvent.index)
        } else {
            print("No matched event: \(qrcode)")
        }
    }
}

#Preview {
    ChecklistView()
}
