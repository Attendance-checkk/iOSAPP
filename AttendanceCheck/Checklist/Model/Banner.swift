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
    Banner(bannerTitle: "앱을 처음 사용하시나요?", bannerImageName: "SWCUAF_Banner_1", bannerURL: LinkURLS.appFirstTimeURL.url),
    Banner(bannerTitle: "이벤트 경품을 확인해보세요!", bannerImageName: "SWCUAF_Banner_2", bannerURL: LinkURLS.eventGiftsURL.url),
    Banner(bannerTitle: "궁금하신 사항이 있으신가요?", bannerImageName: "SWCUAF_Banner_3", bannerURL: LinkURLS.faqURL.url)
]
