//
//  ChecklistTestView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/19/24.
//

import SwiftUI

struct ChecklistTestView: View {
    @EnvironmentObject private var eventManager: EventManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentBannerIndex: Int = 0
    @State private var bannerTimer: Timer? = nil
    @State private var showWebView: Bool = false
    @State private var selectedBannerURL: String = ""
    @State private var timelinePrograms: [TimelinePrograms] = []
    
    private let banners = Banners
    private let animationDuration: Double = 0.5
    private let bannerInterval: TimeInterval = 7.0
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 20) {
                    TabView(selection: $currentBannerIndex) {
                        ForEach(banners.indices, id: \.self) { index in
                            Image(banners[index].bannerImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .onTapGesture {
                                    selectedBannerURL = banners[index].bannerURL
                                    showWebView = true
                                }
                                .tag(index)
                                .background(.clear)
                        }
                        .background(.clear)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(colorScheme == .light ? .black : .clear, lineWidth: 1)
                    )
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 120)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .onAppear {
                        startBannerAnimation()
                    }
                    .onDisappear {
                        stopBannerAnimation()
                    }
                    .onChange(of: currentBannerIndex) { _, _ in
                        resetBannerAnimation()
                    }
                    
                    List {
                        Section(header: Text(changeProgressTitle())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        ) {
                            ProgressView(value: eventManager.progress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        
                        Section(header: Text("스탬프 모으기")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        ) {
                            ForEach(timelinePrograms, id: \.events.event_code) { event in
                                eventRow(for: event)
                            }
                        }
                    }
                    .navigationTitle("체크리스트")
                    .navigationBarTitleDisplayMode(.inline)
                    .sheet(isPresented: $showWebView) {
                        WebView(urlString: selectedBannerURL)
                    }
                }
                .refreshable {
                    eventManager.loadProgramsData { success in
                        if success {
                            print("Refreshable loadProgramsData is completed")
                        } else {
                            print("Refreshable loadProgrmasData is failed")
                        }
                    }
                }
                .onAppear {
                    initTimelinePrograms()
                }
            }
        }
    }
    
    private func initTimelinePrograms() {
        let programs = eventManager.returnProgramsForChecklist()

        timelinePrograms = programs.map { event in
            var status: TimelineStatus
            
            let checkStartTime: Date = dateStringToDate(from: event.event_start_time ?? "10월 18일(수) 12:00") ?? Date()
            let checkEndTime: Date = dateStringToDate(from: event.event_end_time ?? "10월 18일(수) 12:00") ?? Date()
            
            let currentDate = Date()
            
            if currentDate < checkStartTime {
                status = .upcoming
            } else if checkStartTime <= currentDate && currentDate <= checkEndTime {
                status = .inProgress
            } else {
                status = .ended
            }
            
            return TimelinePrograms(events: event, iconName: eventIconName(code: event.event_code), status: status)
        }
    }
    
    private func dateStringToDate(from formattedString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let currentYear = 2024
        let yearAddedString = "\(currentYear)년 \(formattedString)"
        
        dateFormatter.dateFormat = "yyyy년 MM월 d일(E) a h:mm"
        if let date = dateFormatter.date(from: yearAddedString) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy년 MM월 d일(E) HH:mm"
        return dateFormatter.date(from: yearAddedString)
    }
    
    private func eventIconName(code: String) -> String {
        switch code {
        case "SCHUSWCU1stAF_ProjectPresentationParticipation": return "JournalPoster"
        case "SCHUSWCU1stAF_OpeningCeremony": return "OpeningCeremony"
        case "SCHUSWCU1stAF_SWCUGameContest": return "Gamepad"
        case "SCHUSWCU1stAF_TalkConcertwithGraduatedStudent": return "TalkConcert"
        case "SCHUSWCU1stAF_IndustryExpertSpecialLecture": return "SpecialLecture"
        case "SCHUSWCU1stAF_ClosingCeremony": return "Award"
        default: return "marker"
        }
    }
    
    private func detailView(for event: Events) -> some View {
        let title: String = event.event_name
        var detailBannerImageName: String {
            switch event.event_code {
            case "SCHUSWCU1stAF_OpeningCeremony": return "SWCUAF_EVENT_1"
            case "SCHUSWCU1stAF_ProjectPresentationParticipation": return "SWCUAF_EVENT_2"
            case "SCHUSWCU1stAF_SWCUGameContest": return "SWCUAF_EVENT_3"
            case "SCHUSWCU1stAF_TalkConcertwithGraduatedStudent": return "SWCUAF_EVENT_4"
            case "SCHUSWCU1stAF_IndustryExpertSpecialLecture": return "SWCUAF_EVENT_5"
            case "SCHUSWCU1stAF_ClosingCeremony": return "SWCUAF_EVENT_6"
            default: return "SWCUAF_Banner_1"
            }
        }
        
        let location: String = event.location
        let description: String = event.description
        let startTime: String = event.event_start_time ?? "EVENTSTARTTIMEERROR"
        let endTime: String = event.event_end_time ?? "EVENTENDTIMEERROR"
        
        return ChecklistDetailView(eventName: title, detailBannerImageName: detailBannerImageName, eventLocation: location, description: description, startTime: startTime, endTime: endTime)
    }
    
    private func eventRow(for event: TimelinePrograms) -> some View {
        NavigationLink(destination: detailView(for: event.events)) {
            HStack {
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: geometry.size.height, height: geometry.size.height)
                            .foregroundColor(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            }
                        
                        Image(event.iconName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(10)
                            .opacity(eventManager.isEventCompleted(code: event.events.event_code) ? 0.4: 1.0)
                        
                        Image("SCHUCSTAMP")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.height * 0.9, height: geometry.size.height * 0.9)
                            .opacity(eventManager.isEventCompleted(code: event.events.event_code) ? 1.0 : 0.0)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let startTime = event.events.event_start_time {
                        Text(startTime)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if let endTime = event.events.event_end_time {
                        Text(endTime)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(event.events.event_name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.leading)
                
                Spacer()
            }
            .frame(height: 100)
        }
    }
    
    private func changeProgressTitle() -> String {
        return eventManager.progress == 1.0 ? "🥳 스탬프 모으기 완료!" : "스탬프를 모아 경품에 도전해보세요!"
    }
    
    private func startBannerAnimation() {
        bannerTimer = Timer.scheduledTimer(withTimeInterval: bannerInterval, repeats: true) { _ in
            withAnimation {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
    }
    
    private func stopBannerAnimation() {
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    private func resetBannerAnimation() {
        stopBannerAnimation()
        startBannerAnimation()
    }
}

#Preview {
    ChecklistTestView()
}
