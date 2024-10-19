//
//  Programs.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/7/24.
//

import Foundation

struct TimelinePrograms: Codable, Equatable, Hashable {
    var events: Events
    var iconName: String
    var status: TimelineStatus
}

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

struct Participant: Codable, Equatable, Hashable {
    var id: Int
    var createdAt: String
    var user_id: Int
    var event_code: String
}

enum TimelineStatus: String, Codable {
    case inProgress
    case upcoming
    case ended
}
