//
//  AlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

enum AlertType: Identifiable {
    case success
    case loginFailed
    case noDepartmentError
    case departmentFormatError
    case noIDError
    case idFormatError
    case noNameError
    case nameFormatError
    
    var id: String {
        switch self {
        case .success: return "success"
        case .loginFailed: return "loginFailed"
        case .noDepartmentError: return "noDepartmentError"
        case .departmentFormatError: return "departmentFormatError"
        case .noIDError: return "noIDError"
        case .idFormatError: return "idFormatError"
        case .noNameError: return "noNameError"
        case .nameFormatError: return "nameFormatError"
        }
    }
}

