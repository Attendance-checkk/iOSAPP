//
//  ContentView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject var notificationManager: NotificationManager
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isLoginLoading: Bool = false
    @State private var isLoggedIn: Bool = false
    
    @State private var checkAlertType: CheckAlertType?
    @State private var showAlert: Bool = false
    @State private var show430Alert: Bool = false
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    var body: some View {
        ZStack {
            if isLoginLoading {
                ProcessingView(messageString: "로그인 중...")
            } else {
                if userInformation.loginState {
                    MainView()
                        .environmentObject(userInformation)
                        .environmentObject(eventManager)
                        .environmentObject(notificationManager)
                } else {
                    LoginView()
                        .environmentObject(userInformation)
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
        .sheet(isPresented: $show430Alert) {
            Alert430View(
                statusCode: 430,
                title: "⚠️ 서버 요청 횟수 초과",
                message: "서버 요청 횟수가 초과 되었습니다. 잠시 후 다시 사용 가능합니다."
            )
            .environmentObject(userInformation)
        }
        .onAppear {
            
            notificationManager.requestAuthorization()
            notificationManager.authorizationStatusCheck()
            
            isLoginLoading = true
            
            userInformation.fetchUserSettingInfo() { success, statusCode, major, code, name in
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        userInformation.loginState = true
                        isLoginLoading = false
                    }
                } else if statusCode == 401 {
                    accountAlertStatusCode = 401
                    DispatchQueue.main.async {
                        eventManager.clearEventManager()
                        userInformation.loginState = false
                        isLoginLoading = false
                        showAccountAlert = true
                    }
                } else if statusCode == 409 {
                    accountAlertStatusCode = 409
                    DispatchQueue.main.async {
                        eventManager.clearEventManager()
                        userInformation.loginState = false
                        isLoginLoading = false
                        showAccountAlert = true
                    }
                } else if statusCode == 412 {
                    accountAlertStatusCode = 412
                    DispatchQueue.main.async {
                        eventManager.clearEventManager()
                        isLoginLoading = false
                        showAccountAlert = true
                    }
                } else if statusCode == 430 {
                    show430Alert = true
                } else {
                    isLoginLoading = false
                }
            }
        }
        .onChange(of: userInformation.loginState) { newValue in
            if !newValue {
                print("Logout")
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
