//
//  NotificationData.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/16/24.
//

import Foundation

struct NotificationDataByInterval {
    let titleString: String
    let bodyString: String
    let timeIntervalValue: TimeInterval
}

struct NotificationDataByDate {
    let titleString: String
    let bodyString: String
    let date: Date
}
