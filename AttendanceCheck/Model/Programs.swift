//
//  Programs.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/7/24.
//

import Foundation

struct Programs: Codable {
    var events: [Program] = []
}

struct Program: Codable {
    var index: Int
    var title: String
    var location: String
    var description: String
    var qrString: String
}
