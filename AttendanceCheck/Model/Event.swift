//
//  EventStruct.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

struct EventStruct: Identifiable {
    var id = UUID()
    var name: String
    var startTime: Double
    var endTime: Double
    
    var duration: Double {
        return endTime - startTime
    }
}
