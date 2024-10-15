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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if userInformation.loginState {
            MainView()
                .environmentObject(userInformation)
                .environmentObject(eventManager)
                .onAppear {
                    printUserInformation()
                }
        } else {
            LoginView()
                .environmentObject(userInformation)
        }
    }
    
    private func printUserInformation() {
        print(userInformation.department ?? "No Department")
        print(userInformation.studentID ?? "No Student ID")
        print(userInformation.studentName ?? "No Student Name")
        print("Current color mode: \(colorScheme)")
    }
}
