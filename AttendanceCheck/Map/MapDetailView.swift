//
//  MapDetailView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapDetailView: View {
    let floorNumber: Int
    
    var body: some View {
        VStack {
            Image(systemName: "map.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
        }
        .navigationTitle("\(floorNumber + 1)층 지도")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MapDetailView(floorNumber: 1)
}
