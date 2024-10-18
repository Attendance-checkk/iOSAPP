//
//  Banner.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/18/24.
//

import Foundation

struct Banner {
    var bannerTitle: String
    var bannerImageName: String
    var bannerURL: String
}

let Banners: [Banner] = [
    Banner(bannerTitle: "앱을 처음 사용하시나요?", bannerImageName: "SWCUAF_Banner_1", bannerURL: "https://potent-barnacle-025.notion.site/123c07204d2980beb56fededabe0d6a8?pvs=4"),
    Banner(bannerTitle: "이벤트 경품을 확인해보세요!", bannerImageName: "SWCUAF_Banner_2", bannerURL: "https://potent-barnacle-025.notion.site/123c07204d2980d1bed9d435f2b48ed3?pvs=4"),
    Banner(bannerTitle: "궁금하신 사항이 있으신가요?", bannerImageName: "SWCUAF_Banner_3", bannerURL: "https://potent-barnacle-025.notion.site/FAQ-116c07204d29805a8418d9a37bf330a2?pvs=4")
]
