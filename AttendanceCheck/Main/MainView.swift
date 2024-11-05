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
    @State private var show430Alert: Bool = false
    
    @State private var selectedIndex: Int = 2
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            QRView(selectedIndex: $selectedIndex)
                .tabItem {
                    Label("QR", systemImage: "qrcode")
                }
                .tag(0)
            
            ScheduleView(isLoading: $eventManager.isLoading)
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
        .fullScreenCover(isPresented: $showAccountAlert) {
            let warningString = returnWarningTitleAndMessage(statusCode: accountAlertStatusCode)
            
            AccountAlertView(
                statusCode: accountAlertStatusCode,
                title: warningString.title,
                message: warningString.message
            )
            .environmentObject(userInformation)
        }
        .sheet(isPresented: $show430Alert) {
            Alert430View(
                statusCode: 430,
                title: "⚠️ 서버 요청 횟수 초과",
                message: "서버 요청 횟수가 초과 되었습니다. 잠시 후 다시 사용 가능합니다."
            )
            .environmentObject(userInformation)
        }
        .onAppear {
            eventManager.loadProgramsData { success, statusCode, message in
                print("\(success) \(String(describing: statusCode)) \(message)")
                
                if success {
                    print("Refreshable loadProgramsData is completed")
                    eventManager.changeDateFormat() {
                        
                    }
                    
                    if notificationManager.notificationPermissionStatus == .authorized {
                        notificationManager.setupNotifications(eventManager.returnProgramsForTimeline())
                    } else {
                        notificationManager.disableAllNotifications()
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
}
