//
//  UserInformation.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

class UserInformation: ObservableObject {
    @AppStorage("department") var department: String?
    @AppStorage("studentID") var studentID: String?
    @AppStorage("studentName") var studentName: String?
}

class LoginState: ObservableObject {
    @AppStorage("loginState") var loginState: Bool?
}
