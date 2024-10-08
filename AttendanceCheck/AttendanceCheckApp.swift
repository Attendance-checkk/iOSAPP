//
//  AttendanceCheckApp.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import SwiftData

@main
struct AttendanceCheckApp: App {
    @StateObject private var userInformation = UserInformation()
    @StateObject private var loginState = LoginState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userInformation)
                .environmentObject(loginState)
        }
        .modelContainer(sharedModelContainer)
    }
}
