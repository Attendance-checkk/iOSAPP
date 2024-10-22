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
    
    let departmentString: String
    let studentID: String
    let studentName: String
    let faqURL: String = LinkURLS.faqURL.url
    let surveyURL: URL = URL(string: LinkURLS.surveyURL.url)!
    let secureInformationURL: String = LinkURLS.secureInformation.url
    
    @State private var notificationOn: Bool = true
    @State private var showAlert: Bool = false
    @State private var showNotificationAlert: Bool = false
    @State private var isDeleteConfirmed: Bool = false
    @State private var showWebView: Bool = false
    
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
                    .onChange(of: notificationOn) { _, newValue in
                        handleNotificationToggle(isOn: newValue)
                    }
                    
                    NavigationLink(destination: CautionView()) {
                        HStack {
                            Text("⚠️ 계정 삭제 주의사항")
                                .foregroundColor(.red)
                        }
                    }
                    
                    HStack {
                        Button(action: {
                            showAlert = true
                        }) {
                            Text("🗑️ 계정 삭제")
                                .foregroundColor(.red)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("계정 삭제"),
                                  message: Text("정말로 삭제하시겠습니까? 계정은 다시 복구되지 않습니다."),
                                  primaryButton: .destructive(Text("삭제")) {
                                eventManager.clearEventManager()
                                userInformation.userDelete()
                                userInformation.clearUserInformation()
                                  },
                                  secondaryButton: .cancel()
                                  )
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
        .alert(isPresented: $showNotificationAlert) {
            Alert(
                title: Text("알림을 끄시겠습니까?"),
                message: Text("알림을 비활성화하시면 공지를 놓치실 수 있어요!"),
                primaryButton: .destructive(Text("확인")) {
                    NotificationManager.instance.disableAllNotifications()
                },
                secondaryButton: .cancel({
                    notificationOn = true
                    NotificationManager.instance.setupNotifications()
                })
            )
        }
    }
    
    private func handleNotificationToggle(isOn: Bool) {
        if !isOn {
            showNotificationAlert = true
        } else {
            NotificationManager.instance.setupNotifications()
        }
    }
}


#Preview {
    MenuView(departmentString: "사물인터넷학과", studentID: "20181520", studentName: "장경호")
}
