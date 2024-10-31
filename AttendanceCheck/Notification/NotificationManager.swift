//
//  NotificationManager.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/16/24.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let instance = NotificationManager()
    
    enum NotificationPermissionStatus {
        case authorized
        case denied
        case notDetermined
        case provisional // 임시 허용
        case ephemerally // 일시적으로 허용 (iOS 14.5 이상)
    }
    
    @Published var notificationPermissionStatus: NotificationPermissionStatus = .notDetermined
    
    let startTitleString: String = "⏰ 다음 일정이 곧 시작돼요!"
    let endTitleString: String = "⏳ 곧 일정이 종료될 예정이에요!"
    
    lazy var notificationTest: [NotificationDataByInterval] = [
        NotificationDataByInterval(titleString: "개회식이 곧 시작돼요!", bodyString: "개회식에 참여하고 스탬프를 받으세요 ✅", timeIntervalValue: TimeInterval(10)),
        NotificationDataByInterval(titleString: "🎮 게임 경진대회가 곧 시작해요!", bodyString: "여러분의 숨겨진 게임 실력을 보여주세요 👍", timeIntervalValue: TimeInterval(20)),
        NotificationDataByInterval(titleString: "🎮 게임 경진대회가 진행중이에요", bodyString: "참여를 안하신 분들은 6126호로!", timeIntervalValue: TimeInterval(30)),
        NotificationDataByInterval(titleString: "👨‍🎓 졸업생 토크콘서트가 곧 시작해요!", bodyString: "선배님과 즐겁게 이야기해요!", timeIntervalValue: TimeInterval(40)),
        NotificationDataByInterval(titleString: "👨‍🎓 졸업생 토크콘서트가 곧 종료돼요!", bodyString: "아직 묻고 싶은게 남으셨다면 빠르게 달려가세요 🏃", timeIntervalValue: TimeInterval(50)),
        NotificationDataByInterval(titleString: "🎮 게임 경진대회가 진행중이에요", bodyString: "오늘 12시까지만 참여가 가능해요", timeIntervalValue: TimeInterval(60)),
        NotificationDataByInterval(titleString: "👨‍💻 전문가 특강이 곧 시작해요!", bodyString: "사업체 전문가의 이야기들을 들어보세요. 아주 중요한 내용들이 있을지도..?!", timeIntervalValue: TimeInterval(70)),
        NotificationDataByInterval(titleString: "🎮 게임 경진대회가 곧 끝나요!", bodyString: "게임 경진대회는 이제 더 진행되지 않아요!", timeIntervalValue: TimeInterval(80)),
        NotificationDataByInterval(titleString: "👨‍💻 전문가 특강이 곧 끝나요!", bodyString: "아직 놓치고 싶지 않다면 대강당으로!", timeIntervalValue: TimeInterval(90)),
        NotificationDataByInterval(titleString: "곧 시상식과 함께 폐회식이 진행돼요!", bodyString: (EventManager.instance.progress == 1.0) ? "1등 경품의 주인공을 노려보세요!" : "마지막까지 함께해요 🥳", timeIntervalValue: TimeInterval(100))
    ]
    
    lazy var realNotificationSchedule: [NotificationDataByDate] = [
        NotificationDataByDate(titleString: "개회식이 곧 시작돼요!", bodyString: "개회식에 참여하고 스탬프를 받으세요 ✅", date: createDateFromString(dateString: "2024-11-05 10:20")),
        NotificationDataByDate(titleString: "🎮 게임 경진대회가 곧 시작해요!", bodyString: "여러분의 숨겨진 게임 실력을 보여주세요 👍", date: createDateFromString(dateString: "2024-11-05 10:50")),
        NotificationDataByDate(titleString: "🎮 게임 경진대회가 진행중이에요", bodyString: "참여를 안하신 분들은 6126호로!", date: createDateFromString(dateString: "2024-11-05 13:00")),
        NotificationDataByDate(titleString: "👨‍🎓 졸업생 토크콘서트가 곧 시작해요!", bodyString: "선배님과 즐겁게 이야기해요!", date: createDateFromString(dateString: "2024-11-05 13:50")),
        NotificationDataByDate(titleString: "👨‍🎓 졸업생 토크콘서트가 곧 종료돼요!", bodyString: "아직 묻고 싶은게 남으셨다면 빠르게 달려가세요 🏃", date: createDateFromString(dateString: "2024-11-05 15:40")),
        NotificationDataByDate(titleString: "🎮 게임 경진대회가 진행중이에요", bodyString: "오늘 12시까지만 참여가 가능해요", date: createDateFromString(dateString: "2024-11-06 09:30")),
        NotificationDataByDate(titleString: "👨‍💻 전문가 특강이 곧 시작해요!", bodyString: "사업체 전문가의 이야기들을 들어보세요. 아주 중요한 내용들이 있을지도..?!", date: createDateFromString(dateString: "2024-11-06 09:50")),
        NotificationDataByDate(titleString: "🎮 게임 경진대회가 곧 끝나요!", bodyString: "게임 경진대회는 이제 더 진행되지 않아요!", date: createDateFromString(dateString: "2024-11-06 11:30")),
        NotificationDataByDate(titleString: "👨‍💻 전문가 특강이 곧 끝나요!", bodyString: "아직 놓치고 싶지 않다면 대강당으로!", date: createDateFromString(dateString: "2024-11-06 11:40")),
        NotificationDataByDate(titleString: "곧 시상식과 함께 폐회식이 진행돼요!", bodyString: (EventManager.instance.progress == 1.0) ? "1등 경품의 주인공을 노려보세요!" : "마지막까지 함께해요 🥳", date: createDateFromString(dateString: "2024-11-06 14:50"))
    ]
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    
    func requestAuthorization() {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Notification request error: \(error.localizedDescription)")
                    self.notificationPermissionStatus = .denied
                } else {
                    print("Authorization granted: \(success)")
                    self.authorizationStatusCheck()
                }
            }
        }
    
    func authorizationStatusCheck() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.notificationPermissionStatus = .authorized
                } else {
                    self.notificationPermissionStatus = .denied
                    self.disableAllNotifications()
                }
            }
        }
    }
    
    func disableAllNotifications() {
        print("Notification disabled")
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
        print("모든 알림 비활성화")
    }
    
    func setupNotifications() {
        print("Notification setup")
        
        disableAllNotifications()
        
        if notificationPermissionStatus == .authorized {
                for notification in realNotificationSchedule {
                    scheduleNotificationByDate(titleString: notification.titleString, bodyString: notification.bodyString, date: notification.date)
                }
            } else {
                print("Alarm permission is not granted")
            }
    }
    
    func testNotification() {
        print("Notification test start")
        
        for notification in notificationTest {
            scheduleNotificationByInterval(titleString: notification.titleString, bodyString: notification.bodyString, timeIntervalValue: notification.timeIntervalValue)
        }
    }
    
    func scheduleNotificationByInterval(titleString: String, bodyString: String, timeIntervalValue: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = titleString
        content.body = bodyString
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeIntervalValue, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Reservation error: \(error.localizedDescription)")
            } else {
                print("Notification Reservation succeeded: \(request.identifier)")
            }
        }
    }
    
    func scheduleNotificationByDate(titleString: String, bodyString: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = titleString
        content.body = bodyString
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content
                                            , trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Reservation error: \(error.localizedDescription)")
            } else {
                print("Notification Reservation succeeded: \(request.identifier)")
            }
        }
    }
    
    func createDateFromString(dateString: String, format: String = "yyyy-MM-dd HH:mm") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let result = formatter.date(from: dateString) ?? Date()
        
        return result
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
