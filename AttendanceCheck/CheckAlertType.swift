//
//  CheckAlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import SwiftUI

enum CheckAlertType: Identifiable {
    case noUser
    case newDevice
    
    var id: String {
        switch self {
        case .noUser: return "noUser"
        case .newDevice: return "newDevice"
        }
    }
}
