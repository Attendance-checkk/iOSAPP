//
//  ChecklistView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/19/24.
//

import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var notificationManager: NotificationManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    @State private var show430Alert: Bool = false
    
    @State private var currentBannerIndex: Int = 0
    @State private var bannerTimer: Timer? = nil
    @State private var showWebView: Bool = false
    @State private var selectedBannerURL: String = ""
    @State private var timelinePrograms: [TimelinePrograms] = []
    
    @State private var checklistAlertType: ChecklistAlertType? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Binding var isLoading: Bool
    
    enum ShowSheetType: Hashable {
        case web
        case alert430
    }
    
    @State private var showSheetType: ShowSheetType? = nil
    @State private var showSheetBool: Bool = false
    
    private let banners = Banners
    private let animationDuration: Double = 0.5
    private let bannerInterval: TimeInterval = 7.0
    
    var body: some View {
        ZStack {
            if isLoading {
                ProcessingView(messageString: "정보를 가져오는 중입니다..")
                    .transition(.opacity)
                    .ignoresSafeArea(.all)
                
                Color.clear
                    .onTapGesture {
                        print("Checklist view loading...")
                    }
            } else {
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
                                        showSheetType = .web
                                        showSheetBool = true
                                    }
                                    .tag(index)
                                    .background((colorScheme == .light) ? Color.white : Color.black)
                            }
                            .background(.clear)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(colorScheme == .light ? .gray : .clear, lineWidth: 1)
                        )
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 120)
                        .padding(.vertical, 10)
                        .onAppear {
                            startBannerAnimation()
                            eventManager.changeDateFormat() {
                            }
                        }
                        .onDisappear {
                            stopBannerAnimation()
                        }
                        .onChange(of: currentBannerIndex) { _ in
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
                        .scrollIndicators(.hidden)
                        .navigationTitle("체크리스트")
                        .navigationBarTitleDisplayMode(.inline)
                        .sheet(isPresented: $showSheetBool) {
                            if showSheetType == .web {
                                WebView(urlString: selectedBannerURL)
                            } else if showSheetType == .alert430 {
                                Alert430View()
                            }
                        }
                    }
                    .refreshable {
                        eventManager.loadProgramsData { success, statusCode, message in
                            print("\(success) \(String(describing: statusCode)) \(message)")
                            
                            if success {
                                print("Refreshable loadProgramsData is completed")
                                
                                if notificationManager.notificationPermissionStatus == .authorized {
                                    notificationManager.setupNotifications(eventManager.returnProgramsForTimeline())
                                } else {
                                    notificationManager.disableAllNotifications()
                                }
                            } else {
                                switch statusCode {
                                case 401:
                                    print("Token is not valid")
                                    accountAlertStatusCode = 401
                                    DispatchQueue.main.async {
                                        eventManager.clearEventManager()
                                        showAccountAlert = true
                                    }
                                case 409:
                                    accountAlertStatusCode = 409
                                    DispatchQueue.main.async {
                                        eventManager.clearEventManager()
                                        showAccountAlert = true
                                    }
                                case 412:
                                    accountAlertStatusCode = 412
                                    DispatchQueue.main.async {
                                        eventManager.clearEventManager()
                                        showAccountAlert = true
                                    }
                                case 430:
                                    showSheetType = .alert430
                                    DispatchQueue.main.async {
                                        showSheetBool = true
                                    }
                                default: break
                                }
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showAccountAlert) {
                        let warningString = returnWarningTitleAndMessage(statusCode: accountAlertStatusCode)
                        
                        AccountAlertView(
                            statusCode: accountAlertStatusCode,
                            title: warningString.title,
                            message: warningString.message
                        )
                        .environmentObject(userInformation)
                    }
                    .onAppear {
                        initTimelinePrograms()
                    }
                }
            }
        }
    }
    
    private func returnWarningTitleAndMessage(statusCode: Int) -> (title: String, message: String) {
        var warningTitle = ""
        var warningMessage = ""
        
        switch accountAlertStatusCode {
        case 401:
            warningTitle = "⚠️ 토큰 오류"
            warningMessage = "유효하지 않은 토큰을 사용하고 있습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
        case 409:
            warningTitle = "⚠️ 계정 오류"
            warningMessage = "서버에서 사용자 정보가 삭제되었습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
        case 412:
            warningTitle = "⚠️ 중복 로그인"
            warningMessage = "새로운 기기에서 로그인되었습니다.\n이전 기기에서 로그인된 정보는 삭제됩니다."
        default:
            print("Warning")
        }
        
        return (warningTitle, warningMessage)
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
        case getSecurityCode("PPP"): return "JournalPoster"
        case getSecurityCode("OPEN"): return "OpeningCeremony"
        case getSecurityCode("GAME"): return "Gamepad"
        case getSecurityCode("TALK"): return "TalkConcert"
        case getSecurityCode("IESL"): return "SpecialLecture"
        case getSecurityCode("CLOSE"): return "Award"
        case getSecurityCode("LAB"): return "Openlab"
        default: return "marker"
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
            case getSecurityCode("LAB"): return "SWCUAF_EVENT_7"
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
                                    .stroke(colorScheme == .light ? Color.gray : Color.clear, lineWidth: colorScheme == .light ? 1 : 0)
                            }
                        
                        Image(event.iconName)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(10)
                            .opacity(eventManager.isEventCompleted(code: event.events.event_code) ? 0.0 : 1.0)
                        
                        Image("SCHUSTAMP")
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
    
    private func getSecurityCode(_ request: String) -> String {
        if let code = Bundle.main.object(forInfoDictionaryKey: request) as? String {
            return code
        } else {
            return ""
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        let scanner = Scanner(string: hexSanitized)
        
        // scanHexInt64를 사용하여 UInt64로 변환
        guard scanner.scanHexInt64(&rgb) else { return nil }

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
