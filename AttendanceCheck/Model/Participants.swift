//
//  Participants.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import Foundation

struct Participant: Codable, Equatable, Hashable {
    var id: Int
    var createdAt: String
    var user_id: Int
    var event_code: String
}
