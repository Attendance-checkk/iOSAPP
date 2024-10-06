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
                    Label("Location", systemImage: "map.fill")
                }
                .tag(1)
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(2)
            
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
                .tag(3)
            
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "gear")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainView()
}
