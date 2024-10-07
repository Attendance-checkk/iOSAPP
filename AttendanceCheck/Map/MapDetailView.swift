//
//  MapDetailView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MapDetailView: View {
    let floorNumber: Int
    var floorString: String {
        switch floorNumber {
        case 1:
            return "1st floor"
        case 2:
            return "2nd floor"
        case 3:
            return "3rd floor"
        case 4:
            return "4th floor"
        case 5:
            return "5th floor"
        default:
            return "Unknown floor"
        }
    }
    
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
    MapDetailView(floorNumber: 1)
}
