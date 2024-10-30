//
//  MenuView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    let departmentString: String
    let studentID: String
    let studentName: String
    let faqURL: String = LinkURLS.faqURL.url
    let surveyURL: URL = URL(string: LinkURLS.surveyURL.url)!
    let secureInformationURL: String = LinkURLS.secureInformation.url
    
    @State private var showAlert: Bool = false
    @State private var showNotificationAlert: NotificationAlertType? = nil
    @State private var isDeleteConfirmed: Bool = false
    @State private var showWebView: Bool = false
    
    @AppStorage("notificationOn") private var notificationOn: Bool = true
    
    @State private var showWebEnum: ShowWebEnum = .idle
    
    enum ShowWebEnum: String, CaseIterable {
        case idle
        case faq
        case secureInformation
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("학생 정보")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    HStack {
                        Text("학과")
                        Spacer()
                        Text(userInformation.department ?? "DepartmentGetFromAppStorageError")
                    }
                    
                    HStack {
                        Text("학번")
                        Spacer()
                        Text(userInformation.studentID ?? "StudentIDGetFromAppStorageError")
                    }
                    
                    HStack {
                        Text("이름")
                        Spacer()
                        Text(userInformation.studentName ?? "StudentNameGetFromAppStorageError")
                    }
                }
                
                Section(header: Text("링크")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Button(action : {
                        showWebEnum = .faq
                        showWebView.toggle()
                    }) {
                        HStack {
                            Text("🙋 문의하기")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: surveyURL) {
                        HStack {
                            Text("🌐 만족도 조사")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Button(action: {
                        showWebEnum = .secureInformation
                        showWebView.toggle()
                    }) {
                        HStack {
                            Text("🪪 개인정보 처리방침")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("설정")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Toggle(isOn: $notificationOn) {
                        Text("🔔 알림설정")
                    }
                    .disabled(notificationManager.notificationPermissionStatus != .authorized)
                    .onTapGesture {
                        if notificationManager.notificationPermissionStatus != .authorized {
                            showNotificationAlert = .permission
                        }
                    }
                    
                    NavigationLink(destination: CautionView()) {
                        HStack {
                            Text("🗑️ 계정 삭제")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("메뉴")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showWebView) {
                if showWebEnum == .faq {
                    WebView(urlString: faqURL)
                } else if showWebEnum == .secureInformation {
                    WebView(urlString: secureInformationURL)
                }
            }
        }
        .alert(item: $showNotificationAlert) { alert in
            switch alert {
            case .turnoff:
                return Alert(
                    title: Text("알림을 끄시겠습니까?"),
                    message: Text("알림을 비활성화하시면 공지를 놓치실 수 있어요!"),
                    primaryButton: .destructive(Text("확인")) {
                        notificationOn = false
                        notificationManager.disableAllNotifications()
                    },
                    secondaryButton: .cancel({
                        notificationOn = true
                    })
                )
            case .permission:
                return Alert(
                    title: Text("권한이 없습니다!"),
                    message: Text("알림을 켜고 싶으시다면 설정에서 알림을 켜주세요!"),
                    dismissButton: .default(Text("확인")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
        }
        .onAppear {
            notificationManager.authorizationStatusCheck()
            
            if notificationManager.notificationPermissionStatus == .denied {
                notificationOn = false
            } else {
                notificationOn = notificationOn
            }
        }
        .onChange(of: notificationOn) { oldValue, newValue in
            notificationManager.authorizationStatusCheck()
            
            if notificationManager.notificationPermissionStatus != .authorized {
                notificationOn = false
                return
            }
            
            if oldValue == false {
                notificationOn = true
                notificationManager.setupNotifications()
            } else {
                showNotificationAlert = .turnoff
            }
        }
    }
}


#Preview {
    MenuView(departmentString: "사물인터넷학과", studentID: "20181520", studentName: "장경호")
}
