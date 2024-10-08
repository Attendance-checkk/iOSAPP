//
//  AlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

enum AlertType: Identifiable {
    case success
    case idFormatError
    
    var id: String {
        switch self {
        case .success: return "success"
        case .idFormatError: return "idFormatError"
        }
    }
}

