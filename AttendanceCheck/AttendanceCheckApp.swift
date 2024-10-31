//
//  AttendanceCheckApp.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import CoreData

@main
struct AttendanceCheckApp: App {
    @StateObject private var userInformation = UserInformation()
    @StateObject private var eventManager = EventManager()
    @StateObject private var notificationManager = NotificationManager()
    
    // Core Data Stack
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AttendanceCheck") // Core Data 모델 이름
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    init() {
        
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userInformation)
                .environmentObject(eventManager)
                .environmentObject(notificationManager)
                .environment(\.managedObjectContext, persistentContainer.viewContext) // Core Data Context 제공
        }
    }
}
