//
//  CampusLocation.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/18/24.
//

import Foundation

struct CampusLocation: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let position: CGPoint
}

let campusLocations = [
    CampusLocation(name: "인문과학관", code: "6", position: CGPoint(x: 100, y: 150))
]
