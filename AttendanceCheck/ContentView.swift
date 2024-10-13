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
    @EnvironmentObject private var loginState: LoginState
    @EnvironmentObject private var eventManager: EventManager
    
    var body: some View {
        if loginState.loginState ?? false {
            MainView()
                .environmentObject(userInformation)
                .environmentObject(loginState)
                .environmentObject(eventManager)
                .onAppear {
                    printUserInformation()
                }
        } else {
            LoginView()
                .environmentObject(userInformation)
                .environmentObject(loginState)
        }
    }
    
    private func printUserInformation() {
        print(userInformation.department ?? "No Department")
        print(userInformation.studentID ?? "No Student ID")
        print(userInformation.studentName ?? "No Student Name")
    }
}
