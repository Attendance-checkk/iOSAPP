//
//  DeviceModel.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/18/24.
//

import UIKit

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            print("Device model: \(identifier + String(UnicodeScalar(UInt8(value))))")
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
