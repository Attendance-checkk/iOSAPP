//
//  LinkURLS.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/19/24.
//

import Foundation

enum LinkURLS: Identifiable {
    case appFirstTimeURL
    case eventGiftsURL
    case faqURL
    case surveyURL
    case privacyPolicy
    
    var id: String {
        switch self {
        case .appFirstTimeURL: return "appFirstTimeURL"
        case .eventGiftsURL: return "eventGiftsURL"
        case .faqURL: return "faqURL"
        case .surveyURL: return "surveyURL"
        case .privacyPolicy: return "privacyPolicy"
        }
    }
    
    var url: String {
        switch self {
        case .appFirstTimeURL: return "https://potent-barnacle-025.notion.site/iOS-130c07204d29802da3f4da335a37ab9e?pvs=4"
        case .eventGiftsURL: return "https://potent-barnacle-025.notion.site/123c07204d2980d1bed9d435f2b48ed3?pvs=4"
        case .faqURL: return "https://potent-barnacle-025.notion.site/FAQ-116c07204d29805a8418d9a37bf330a2?pvs=4"
        case .surveyURL: return "https://forms.gle/1PbtPMTjptGnUGTU9"
        case .privacyPolicy: return "https://potent-barnacle-025.notion.site/124c07204d2980ffa767d3a24b3e18b8?pvs=4"
        }
    }
}
