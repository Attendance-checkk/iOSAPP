//
//  QRAlretType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/15/24.
//

import SwiftUI

enum QRAlretType {
    case success
    case alreadyScanned
    case unknownCode
    case unknownError
    case permission
    
    var title: String {
        switch self {
        case .success: return "인식이 완료되었습니다!"
        case .alreadyScanned: return "이미 인식한 코드입니다"
        case .unknownCode: return "코드 형식이 맞지 않습니다"
        case .unknownError: return "알 수 없는 오류가 발생했습니다"
        case .permission: return "카메라 권한 오류"
        }
    }
    
    var message: String {
        switch self {
        case .success: return "스탬프를 찍었어요! 🥳"
        case .alreadyScanned: return "인식한 코드는 다시 인식할 수 없어요.. 🥲"
        case .unknownCode: return "코드가 이상한 것 같아요 🤔"
        case .unknownError: return "관리자에게 문의해주세요..!"
        case .permission: return "카메라 권한이 없으면 QR코드를 인식할 수 없습니다!"
        }
    }
}

