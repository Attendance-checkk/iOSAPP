//
//  QRAlertType.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/15/24.
//

import SwiftUI

enum QRAlertType {
    case success
    case alreadyScanned
    case unknownCode
    case unknownError
    case permission
    case noUser
    case newDevice
    case notYet
    case closedEvent
    
    var title: String {
        switch self {
        case .success: return "인식이 완료되었습니다!"
        case .alreadyScanned: return "이미 인식한 코드입니다"
        case .unknownCode: return "코드 형식이 맞지 않습니다"
        case .unknownError: return "알 수 없는 오류가 발생했습니다"
        case .permission: return "권한이 없습니다!"
        case .noUser: return "사용자 정보가 없습니다"
        case .newDevice: return "새 디바이스 등록"
        case .notYet: return "이벤트 시작 전"
        case .closedEvent: return "이벤트 종료됨"
        }
    }
    
    var message: String {
        switch self {
        case .success: return "스탬프를 찍었어요! 🥳"
        case .alreadyScanned: return "인식한 코드는 다시 인식할 수 없어요.. 🥲"
        case .unknownCode: return "코드가 이상한 것 같아요 🤔"
        case .unknownError: return "관리자에게 문의해주세요..!"
        case .permission: return "카메라 권한이 없으면 QR코드를 인식할 수 없습니다!"
        case .noUser: return "삭제된 사용자입니다!"
        case .newDevice: return "새로운 기기가 등록되었습니다! 해당 기기에서는 자동으로 로그아웃됩니다"
        case .notYet: return "이벤트가 시작하기 전입니다!"
        case .closedEvent: return "이미 종료된 이벤트입니다!"
        }
    }
}

