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
                    ForEach(0..<5) { index in
                        NavigationLink(destination: MapDetailView(floorNumber: index)) {
                            Text("\(index + 1)층")
                        }
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
