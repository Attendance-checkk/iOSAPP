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
    
    let eventManager = EventManager.instance
    let startTitleString: String = "⏰ 다음 일정이 곧 시작돼요!"
    let endTitleString: String = "⏳ 곧 일정이 종료될 예정이에요!"
    
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
            for notification in makeNotificationList() {
                scheduleNotificationByDate(titleString: notification.titleString, bodyString: notification.bodyString, date: notification.date)
            }
        } else {
            print("Alarm permission is not granted")
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
    
    func makeNotificationList() -> [NotificationDataByDate] {
        let timelinePrograms = eventManager.returnProgramsForTimeline()
        var notificationList: [NotificationDataByDate] = []
        
        for program in timelinePrograms {
            if let startTimeString = program.event_start_time,
               let startTime = dateStringToDate(from: startTimeString) {
                
                var notificationTitle = "\(program.event_name)이 곧 시작됩니다!"
                var notificationDescription = "\(program.event_name)이(가) 시작돼요! 🎉"
                
                switch program.event_code {
                case getSecurityCode("PPP"):
                    notificationTitle = "SW융합대학 경진대회가 곧 시작됩니다!"
                    notificationDescription = "본선 관람하고 스탬프도 받아보세요 ✅"
                case getSecurityCode("OPEN"):
                    notificationTitle = "개회식이 곧 시작됩니다!"
                    notificationDescription = "SW융합대학 첫 학술제의 개회식이 시작돼요! 🎉"
                case getSecurityCode("GAME"):
                    notificationTitle = "게임 경진대회에 참여해보세요!"
                    notificationDescription = "게임 경진대회가 곧 시작돼요! 3번까지 참여 가능하니 1등을 노려보세요! 🎮"
                case getSecurityCode("TALK"):
                    notificationTitle = "곧 졸업생 토크콘서트가 시작됩니다!"
                    notificationDescription = "곧 졸업생 토크콘서트가 시작돼요! 선배님들과 즐거운 시간 보내세요! 🙋‍♂️"
                case getSecurityCode("IESL"):
                    notificationTitle = "사업체 전문가 특강이 진행될 예정입니다!"
                    notificationDescription = "사업체 전문가 분들의 특강을 들을 수 있어요! 👨‍🏫"
                case getSecurityCode("CLOSE"):
                    notificationTitle = "마지막 일정인 폐회식과 시상식이 진행됩니다!"
                    notificationDescription = "학술제의 마지막 행사인 폐회식과 시상식이 진행돼요! 마지막까지 함께해주세요 🏆"
                default:
                    notificationDescription = ""
                }
                
                // 20분 전 알림 시간 계산
                let notificationTime = startTime.addingTimeInterval(-20 * 60)
                
                let startNotification = NotificationDataByDate(
                    titleString: notificationTitle,
                    bodyString: notificationDescription,
                    date: notificationTime
                )
                notificationList.append(startNotification)
            }
        }
        
        return notificationList
    }
    
    private func getSecurityCode(_ request: String) -> String {
        if let code = Bundle.main.object(forInfoDictionaryKey: request) as? String {
            return code
        } else {
            return ""
        }
    }
    
    private func dateStringToDate(from formattedString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let currentYear = 2024
        let yearAddedString = "\(currentYear)년 \(formattedString)"
        
        // 12시간 형식
        dateFormatter.dateFormat = "yyyy년 MM월 dd일(EEE) a h:mm"
        if let date = dateFormatter.date(from: yearAddedString) {
            return date
        }
        
        // 24시간 형식
        dateFormatter.dateFormat = "yyyy년 MM월 dd일(EEE) HH:mm"
        return dateFormatter.date(from: yearAddedString)
    }
}
