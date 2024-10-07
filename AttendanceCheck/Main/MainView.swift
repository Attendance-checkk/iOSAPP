//
//  MainView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MainView: View {
    @State private var selectedIndex: Int = 2
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            QRView()
                .tabItem {
                    Label("QR", systemImage: "qrcode")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("위치", systemImage: "map.fill")
                }
                .tag(1)
                
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(2)
            
            ScheduleView()
                .tabItem {
                    Label("일정", systemImage: "calendar")
                }
                .tag(3)
            
            MenuView(departmentString: "사물인터넷학과", studentNumber: "20181520", studentName: "장경호")
                .tabItem {
                    Label("메뉴", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainView()
}
