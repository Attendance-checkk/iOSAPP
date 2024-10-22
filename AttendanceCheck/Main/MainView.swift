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
    
    @State private var selectedIndex: Int = 2
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            QRView(selectedIndex: $selectedIndex)
                .tabItem {
                    Label("QR", systemImage: "qrcode")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("지도", systemImage: "map.fill")
                }
                .tag(1)
            
            ChecklistTestView()
                .tabItem {
                    Label("체크리스트", systemImage: "checkmark.seal")
                }
                .tag(2)
            
            ScheduleView()
                .tabItem {
                    Label("일정", systemImage: "calendar")
                }
                .tag(3)
            
            MenuView(departmentString: userInformation.department ?? "DepartmentGetFromAppStorageError", studentID: userInformation.studentID ?? "StudentIDGetFromAppStorageError", studentName: userInformation.studentName ?? "StudentNameGetFromAppStorageError")
                .tabItem {
                    Label("메뉴", systemImage: "gear")
                }
                .tag(4)
            }
        .onAppear {
            userInformation.login { success in
                print("Login success: \(success)")
            }

                
            let jwt = userInformation.accessToken
            print("Java Web Token: \(jwt)")
        }
    }
}

#Preview {
    MainView()
}
