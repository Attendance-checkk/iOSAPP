//
//  EventManager.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/12/24.
//

import SwiftUI

class EventManager: ObservableObject {
    @AppStorage("completedEvents") var completedEvents: String = ""
    
    @AppStorage("event1") var event1: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event2") var event2: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event3") var event3: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event4") var event4: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event5") var event5: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event6") var event6: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event7") var event7: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event8") var event8: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("event9") var event9: Bool = false {
        didSet { objectWillChange.send() }
    }
    @AppStorage("progress") var progress: Double = 0.0
    
    @Published var programs: Programs? = nil
    @Published var isLoading: Bool = true
    @Published var eventsCompletion: [Bool] = [false, false, false, false, false, false, false, false, false]
    
    private var userInformation: UserInformation
    
    init(userInformation: UserInformation) {
        self.userInformation = userInformation
        loadProgramsData()
    }
    
    public func isEventCompleted(index: Int) -> Bool {
        print("isEventCompleted function called: \(index)")
        
        switch index {
        case 0: return event1
        case 1: return event2
        case 2: return event3
        case 3: return event4
        case 4: return event5
        case 5: return event6
        case 6: return event7
        case 7: return event8
        case 8: return event9
        default: return false
        }
    }
    
    // MARK: - API(POST event code to server) 01(External)
    public func completeEventByQRCode(_ qrcode: String) {
        print("completeEventByQRCode function called: \(qrcode)")
        
        isLoading = true
        
        eventPost(qrcode) { success, statusCode, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard success else {
                    print("이벤트 처리 실패: \(statusCode ?? -1), \(message ?? "알 수 없는 오류")")
                    return
                }
                
                for (index, event) in self.programs?.events.enumerated() ?? [].enumerated() {
                    if event.eventCode == qrcode {
                        self.markEventAsCompleted(index: index)
                        self.calculateProgress()
                        break
                    }
                }
            }
        }
    }
    
    // MARK: - API(POST event code to server) 02(Internal)
    private func eventPost(_ qrcode: String, completion: @escaping (Bool, Int?, String?) -> Void) {
        print("Event POST: \(qrcode)")
        
        guard let token = userInformation.accessToken else {
            completion(false, 800, "No token")
            return
        }
        
        let parameters = "{\r\n    \"event_code\" : \"\(qrcode)\"\r\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "http://54.180.7.191:9999/user/attendance")!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("everntPostError: \(error)")
                completion(false, 801, "네트워크 오류: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(false, 802, "데이터 또는 응답 오류")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = jsonResponse["message"] as? String {
                        print("Event POST success: \(httpResponse.statusCode), \(message)")
                        completion(true, 200, message)
                    } else {
                        completion(false, 400, "응답 형식 오류")
                    }
                } catch {
                    print("JSON parsing error: \(error)")
                    completion(false, 803, "JSON 파싱 오류")
                }
            case 401:
                print("eventPostError: \(httpResponse.statusCode), 이미 등록된 코드입니다.")
                completion(false, 401, "이미 등록된 코드입니다.")
                
            case 402:
                print("eventPostError: \(httpResponse.statusCode), 존재하지 않는 코드입니다.")
                completion(false, 402, "존재하지 않는 코드입니다.")
                
            default:
                print("eventPostError: 응답 코드 \(httpResponse.statusCode), 알 수 없는 오류 발생")
                completion(false, httpResponse.statusCode, "응답 오류 발생")
            }
        }

        task.resume()
    }
    
    private func calculateProgress() {
        print("calculateProgress function called")
        
        var newProgress: Double = 0.0
        
        if event1 { newProgress += 0.2 }
        if event2 { newProgress += 0.2 }
        if event3 || event4 || event5 || event6 || event7 { newProgress += 0.2 }
        if event8 { newProgress += 0.2 }
        if event9 { newProgress += 0.2 }
        
        progress = min(newProgress, 1.0)
    }
    
    private func markEventAsCompleted(index: Int) {
        print("markEventAsCompleted function called: \(index)")
        
        eventsCompletion[index] = true
        
        switch index {
        case 0: event1 = true
        case 1: event2 = true
        case 2: event3 = true
        case 3: event4 = true
        case 4: event5 = true
        case 5: event6 = true
        case 6: event7 = true
        case 7: event8 = true
        case 8: event9 = true
        default: break
        }
    }
    
    // MARK: - API(GET event list) 01(External)
    public func loadProgramsData() {
        if let loadedPrograms = loadPrograms(from: "Programs") {
            programs = loadedPrograms
            
            isLoading = false
        } else {
            print("Failed to load programs")
        }
    }
    
    // MARK: - API(GET event list) 02(Internal)
    private func loadPrograms(from fileName: String) -> Programs? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Cannot find JSON file: \(fileName).json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let programs = try JSONDecoder().decode(Programs.self, from: data)
            
            return programs
        } catch {
            print("JSON decoding error: \(error.localizedDescription)")
            return nil
        }
    }
    
//    public func loadEventsData() {
//        if let loadedEvents =
//    }
//    
//    public func loadEvents(from fileName: String) -> Events? {
//        
//    }
    
    public func clearEventManager() {
        event1 = false
        event2 = false
        event3 = false
        event4 = false
        event5 = false
        event6 = false
        event7 = false
        event8 = false
        event9 = false
        progress = 0.0
        
        completedEvents = ""
        
        print("All events cleared")
    }
}
