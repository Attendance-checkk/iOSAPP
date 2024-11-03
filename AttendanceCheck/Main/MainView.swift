//
//  MainView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @State private var selectedIndex: Int = 2
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            QRView(selectedIndex: $selectedIndex)
                .tabItem {
                    Label("QR", systemImage: "qrcode")
                }
                .tag(0)
            
            ScheduleView()
                .tabItem {
                    Label("일정", systemImage: "calendar")
                }
                .tag(1)
            
            ChecklistView(isLoading: $eventManager.isLoading)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(2)
            
            MapView()
                .tabItem {
                    Label("지도", systemImage: "map.fill")
                }
                .tag(3)
            
            MenuView(departmentString: userInformation.department ?? "DepartmentGetFromAppStorageError", studentID: userInformation.studentID ?? "StudentIDGetFromAppStorageError", studentName: userInformation.studentName ?? "StudentNameGetFromAppStorageError")
                .tabItem {
                    Label("메뉴", systemImage: "gear")
                }
                .tag(4)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onAppear {
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
                    default: break
                    }
                }
            }
        }
    }
}
