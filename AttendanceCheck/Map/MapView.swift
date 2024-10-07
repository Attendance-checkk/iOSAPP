//
//  MapView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: MapDetailView(floorNumber: 1)) {
                        Text("1층")
                    }
                    NavigationLink(destination: MapDetailView(floorNumber: 2)) {
                        Text("2층")
                    }
                    NavigationLink(destination: MapDetailView(floorNumber: 3)) {
                        Text("3층")
                    }
                    NavigationLink(destination: MapDetailView(floorNumber: 4)) {
                        Text("4층")
                    }
                    NavigationLink(destination: MapDetailView(floorNumber: 5)) {
                        Text("5층")
                    }
                }
            }
            .navigationTitle("위치")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MapView()
}
