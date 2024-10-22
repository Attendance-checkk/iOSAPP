//
//  ChecklistView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var eventManager: EventManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentBannerIndex: Int = 0
    @State private var bannerTimer: Timer? = nil
    @State private var showWebView: Bool = false
    @State private var selectedBannerURL: String = ""
    
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
                    .padding(.top, 20)
                    .onAppear {
                        startBannerAnimation()
                    }
                    .onDisappear {
                        stopBannerAnimation()
                    }
                    .onChange(of: currentBannerIndex) { _, _ in
                        resetBannerAnimation()
                    }
                    Text(changeProgressTitle())
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    
                    ProgressView(value: eventManager.progress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal, 30)
                    
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
                        .refreshable {
                            eventManager.loadProgramsData { success in
                                if success {
                                    print("Refreshable loadProgramsData is completed")
                                } else {
                                    print("Refreshable loadProgrmasData is failed")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("체크리스트")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showWebView) {
                    WebView(urlString: selectedBannerURL)
                }
            }
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
            default: return "SWCUAF_Banner_1"
            }
        }
        
        let location: String = event.location
        let description: String = event.description
        let startTime: String = event.event_start_time ?? "EVENTSTARTTIMEERROR"
        let endTime: String = event.event_end_time ?? "EVENTENDTIMEERROR"
        
        return ChecklistDetailView(eventName: title, detailBannerImageName: detailBannerImageName, eventLocation: location, description: description, startTime: startTime, endTime: endTime)
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
    ChecklistView()
}
