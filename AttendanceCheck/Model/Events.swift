//
//  Events.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import Foundation

struct Events: Codable, Equatable, Hashable {
    var event_code: String
    var event_name: String
    var description: String
    var location: String
    var event_start_time: String?
    var event_end_time: String?
    var createdAt: String
    var participants: [Participant]?
}
