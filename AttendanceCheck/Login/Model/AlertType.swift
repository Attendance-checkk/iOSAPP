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
    case noPasswordError
    case passwordFormatError
    case passwordDifferentError
    case recheck
    case alreadyRegistered
    case savedPasswordDifferentError
    case userInformationDifferentError
    case networkError
    
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
        case .noPasswordError: return "noPasswordError"
        case .passwordFormatError: return "passwordFormatError"
        case .passwordDifferentError: return "passwordDifferentError"
        case .recheck: return "recheck"
        case .alreadyRegistered: return "alreadyRegistered"
        case .savedPasswordDifferentError: return "savedPasswordDifferentError"
        case .userInformationDifferentError: return "userInformationDifferentError"
        case .networkError: return "networkError"
        }
    }
}

