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
    
    var body: some View {
        if userInformation.loginState {
            MainView()
                .environmentObject(userInformation)
                .environmentObject(eventManager)
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.authorizationStatusCheck()
                }
        } else {
            LoginView()
                .environmentObject(userInformation)
                .onAppear {
                    notificationManager.requestAuthorization()
                    notificationManager.authorizationStatusCheck()
                }
        }
    }
}
