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
        .onAppear {
            print("Current login state: \(userInformation.loginState)")
            print("Current stored login state: \(userInformation.storedLoginState ?? false)")
            
            notificationManager.requestAuthorization()
            notificationManager.authorizationStatusCheck()
            
            isLoginLoading = true
            
            userInformation.fetchUserSettingInfo() { success, statusCode, major, code, name in
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        userInformation.loginState = true
                        isLoginLoading = false
                    }
                } else if statusCode == 409 || statusCode == 412 {
                    DispatchQueue.main.async {
                        userInformation.loginState = false
                        isLoginLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        isLoginLoading = false
                    }
                }
            }
        }
        .onChange(of: userInformation.loginState) { newValue in
            if !newValue {
                print("Logout")
            }
        }
    }
}
