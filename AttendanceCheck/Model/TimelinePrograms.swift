//
//  TimelinePrograms.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import Foundation

struct TimelinePrograms: Codable, Equatable, Hashable {
    var events: Events
    var iconName: String
    var status: TimelineStatus
}
