//
//  NotificationAlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/30/24.
//

import SwiftUI

enum NotificationAlertType: Identifiable {
    case turnoff
    case permission
    
    var id: String {
        switch self {
        case .turnoff: return "turnoff"
        case .permission: return "permission"
        }
    }
}
