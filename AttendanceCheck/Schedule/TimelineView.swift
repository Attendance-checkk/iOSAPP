//
//  TimelineView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/19/24.
//

import SwiftUI

struct TimelineView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String?
    
    @State private var timelinePrograms: [TimelinePrograms] = []
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("진행 중")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                ) {
                    ForEach(timelinePrograms.filter { $0.status == .inProgress }, id: \.events.event_code) { program in
                        eventRow(for: program)
                    }
                }
                
                Section(header: Text("진행 예정")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                ) {
                    ForEach(timelinePrograms.filter { $0.status == .upcoming }, id: \.events.event_code) { program in
                        eventRow(for: program)
                    }
                }
                
                Section(header: Text("종료됨")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                ) {
                    ForEach(timelinePrograms.filter { $0.status == .ended }, id: \.events.event_code) { program in
                        eventRow(for: program)
                    }
                }
            }
            .padding(.top, 0)
            .padding(.bottom, 0)
            .onAppear {
                initTimelinePrograms()
            }
            .refreshable {
                eventManager.loadProgramsData { success, statusCode, message in
                    if success {
                        print("Refreshable loadProgramsData is completed")
                        
                        if notificationManager.notificationPermissionStatus == .authorized {
                            notificationManager.setupNotifications(eventManager.returnProgramsForTimeline())
                        } else {
                            notificationManager.disableAllNotifications()
                        }
                        
                        initTimelinePrograms()
                    } else {
                        switch statusCode {
                        case 409:
                            accountAlertMessage = "서버에서 사용자 정보가 삭제되었습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
                            accountAlertStatusCode = 409
                            DispatchQueue.main.async {
                                showAccountAlert = true
                            }
                        case 412:
                            accountAlertMessage = "새로운 기기에서 로그인되었습니다.\n이전 기기에서 로그인된 정보는 삭제됩니다."
                            accountAlertStatusCode = 412
                            DispatchQueue.main.async {
                                showAccountAlert = true
                            }
                        case 429:
                            alertMessage = "너무 많은 로그인 요청을 단시간에 전송하여 일정 시간 접근이 제한됩니다."
                            showAlert = true
                        case 430:
                            alertMessage = "너무 많은 요청을 단시간에 전송하여 접근이 제한되었습니다."
                            showAlert = true
                        default:
                            break
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림"), message: Text(alertMessage ?? "ALERT"), dismissButton: .default(Text("확인")) {
                    
                    userInformation.loginState = false
                    userInformation.storedLoginState = false
                    print("userInformation.loginState = \(userInformation.loginState)")
                })
            }
            .fullScreenCover(isPresented: $showAccountAlert) {
                AccountAlertView(
                    statusCode: accountAlertStatusCode,
                    message: accountAlertMessage
                )
                .environmentObject(userInformation)
            }
        }
    }
    
    private func initTimelinePrograms() {
        let programs = eventManager.returnProgramsForTimeline()

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
        case getSecurityCode("PPP"): return "JournalPoster"
        case getSecurityCode("OPEN"): return "OpeningCeremony"
        case getSecurityCode("GAME"): return "Gamepad"
        case getSecurityCode("TALK"): return "TalkConcert"
        case getSecurityCode("IESL"): return "SpecialLecture"
        case getSecurityCode("CLOSE"): return "Award"
        default: return "marker"
        }
    }
    
    private func eventRow(for program: TimelinePrograms) -> some View {
        NavigationLink(destination: detailView(for: program.events)) {
            HStack {
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: geometry.size.height, height: geometry.size.height)
                            .foregroundColor(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((colorScheme == .light) ? .gray : Color.clear, lineWidth: 1)
                            }
                        
                        Image(program.iconName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(10)
                    }
                }
                .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let startTime = program.events.event_start_time {
                        Text(startTime)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    if let endTime = program.events.event_end_time {
                        Text(endTime)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(program.events.event_name)
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
    
    private func detailView(for event: Events) -> some View {
        let title: String = event.event_name
        var detailBannerImageName: String {
            switch event.event_code {
            case getSecurityCode("OPEN"): return "SWCUAF_EVENT_1"
            case getSecurityCode("PPP"): return "SWCUAF_EVENT_2"
            case getSecurityCode("GAME"): return "SWCUAF_EVENT_3"
            case getSecurityCode("TALK"): return "SWCUAF_EVENT_4"
            case getSecurityCode("IESL"): return "SWCUAF_EVENT_5"
            case getSecurityCode("CLOSE"): return "SWCUAF_EVENT_6"
            default: return "SWCUAF_Banner_1"
            }
        }
        
        let location: String = event.location
        let description: String = event.description
        let startTime: String = event.event_start_time ?? "EVENTSTARTTIMEERROR"
        let endTime: String = event.event_end_time ?? "EVENTENDTIMEERROR"
        
        return ChecklistDetailView(eventName: title, detailBannerImageName: detailBannerImageName, eventLocation: location, description: description, startTime: startTime, endTime: endTime)
    }
    
    private func getSecurityCode(_ request: String) -> String {
        if let code = Bundle.main.object(forInfoDictionaryKey: request) as? String {
            return code
        } else {
            return ""
        }
    }
}

#Preview {
    TimelineView()
}
