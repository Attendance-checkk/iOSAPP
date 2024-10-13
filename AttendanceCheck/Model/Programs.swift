//
//  Programs.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/7/24.
//

import Foundation

struct Programs: Codable, Equatable {
    var events: [Program] = []
    
    static func == (lhs: Programs, rhs: Programs) -> Bool {
        return lhs.events == rhs.events
    }
}

struct Program: Codable, Equatable {
    var index: Int
    var title: String
    var location: String
    var descriptionString: String
    var qrString: String
}
