//
//  MapDetailView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapDetailView: View {
    let floorNumber: Int
    var floorString: String
    
    var body: some View {
        VStack {
            Image(systemName: "map.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
        }
        .navigationTitle(floorString)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MapDetailView(floorNumber: 1, floorString: "1층 지도")
}
