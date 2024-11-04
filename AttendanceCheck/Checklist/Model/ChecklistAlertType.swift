//
//  ChecklistAlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/4/24.
//

import SwiftUI

enum ChecklistAlertType: Identifiable {
    case tooManyAPIRequests
    
    var id: String {
        switch self {
        case .tooManyAPIRequests: return "tooManyAPIRequests"
        }
    }
}
