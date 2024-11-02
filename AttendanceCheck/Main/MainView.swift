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
            
            ChecklistView()
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
        .disabled(eventManager.isLoading)
        .onAppear {
            userInformation.login { success, statusCode, message in
                print("Login success: \(String(describing: statusCode))")
                print("userInformation.loginState: \(userInformation.loginState)")
            }

                
            guard let jwt = userInformation.accessToken else {
                return
            }
            print("Java Web Token: \(jwt)")
        }
    }
}

#Preview {
    MainView()
}
