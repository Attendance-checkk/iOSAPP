//
//  EventManager.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/12/24.
//

import SwiftUI

class EventManager: ObservableObject {
    static let instance = EventManager(userInformation: UserInformation.instance)
    
    private let eventCodeToIndex: [String: Int] = [
        "SCHUSWCU1stAF_OpeningCeremony": 0,
        "SCHUSWCU1stAF_ProjectPresentationParticipation": 1,
        "SCHUSWCU1stAF_GraduatedTalkConcert_01": 2,
        "SCHUSWCU1stAF_GraduatedTalkConcert_02": 3,
        "SCHUSWCU1stAF_GraduatedTalkConcert_03": 4,
        "SCHUSWCU1stAF_GraduatedTalkConcert_04": 5,
        "SCHUSWCU1stAF_GraduatedTalkConcert_05": 6,
        "SCHUSWCU1stAF_SWCUGameContest": 7,
        "SCHUSWCU1stAF_IndustryExpertSpecialLecture": 8
    ]
    
    @Published var event1: Bool = false
    @Published var event2: Bool = false
    @Published var event3: Bool = false
    @Published var event4: Bool = false
    @Published var event5: Bool = false
    @Published var event6: Bool = false
    @Published var event7: Bool = false
    @Published var event8: Bool = false
    @Published var event9: Bool = false
    @Published var progress: Double = 0.0
    
    @Published var programs: [Events]? = nil
    @Published var isLoading: Bool = true
    
    private var userInformation: UserInformation
    
    init(userInformation: UserInformation) {
        self.userInformation = userInformation
        loadProgramsData { success in
            if success {
                print("loadProgramsData_init success")
            } else {
                print("loadProgramsData_init failed")
            }
        }
    }
    
    public func isEventCompleted(code: String) -> Bool {
        guard let index = eventCodeToIndex[code] else {
            return false
        }
        
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
    public func completeEventByQRCode(_ qrcode: String, completion: @escaping(Bool, Int?, String?) -> Void) {
        print("completeEventByQRCode function called: \(qrcode)")
        
        isLoading = true
        
        eventPost(qrcode) { success, statusCode, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard success else {
                    print("이벤트 처리 실패: \(statusCode ?? -1), \(message ?? "알 수 없는 오류")")
                    completion(false, statusCode, message)
                    return
                }
                
                for (_, event) in self.programs?.enumerated() ?? [].enumerated() {
                    if event.event_code == qrcode {
                        self.markEventAsCompleted(code: event.event_code)
                        self.calculateProgress()
                        completion(true, statusCode, nil)
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
        if event3 || event4 || event5 || event6 || event7 {
            newProgress += 0.2
        }
        if event8 { newProgress += 0.2 }
        if event9 { newProgress += 0.2 }
        
        progress = min(newProgress, 1.0)
    }
    
    private func markEventAsCompleted(code: String) {
        if let index = eventCodeToIndex[code] {
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
    }
    
    public func isAlreadyScanned(code: String) -> Bool {
        guard let program = programs?.first(where: { $0.event_code == code }) else {
            return false
        }
        
        return !(program.participants?.isEmpty ?? false)
    }
    
    // MARK: - API(GET event list) 01(External)
    public func loadProgramsData(completion: @escaping(Bool) -> Void) {
        self.isLoading = true
        
        loadPrograms { success, statusCode, message in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    print("Successfully GET events")
                    if let programs = self.programs {
                        self.checkSuccessStatus(programs)
                        self.objectWillChange.send()
                        self.changeDateFormat()
                        completion(true)
                    } else {
                        print("No programs found")
                        completion(false)
                    }
                } else {
                    print("GET event failed with status code: \(statusCode ?? 0), message: \(message)")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - API(GET event list) 02(Internal)
    private func loadPrograms(completion: @escaping(Bool, Int?, String) -> Void) {
        guard let token = userInformation.accessToken else {
            print("No token existed")
            completion(false, 800, "No token existed")
            return
        }
        
        var request = URLRequest(url: URL(string: "http://54.180.7.191:9999/user/event/list")!,timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")

        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Network error: \(String(describing: error))")
                completion(false, 801, "\(String(describing: error))")
                return
            }
            
            do {
                let programs = try JSONDecoder().decode([Events].self, from: data)
                DispatchQueue.main.async {
                    self.programs = programs
                    completion(true, 200, "events GET success")
                }
            } catch {
                print("JSON decoding error: \(error.localizedDescription)")
                completion(false, 802, "\(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
    // MARK: - Initial events success status checking
    private func checkSuccessStatus(_ events: [Events]) {
        for event in events {
            if let participants = event.participants, !participants.isEmpty {
                markEventAsCompleted(code: event.event_code)
            }
        }
        
        calculateProgress()
    }
    
    public func changeDateFormat() {
        guard let programs = programs else {
            print("No programs available")
            return
        }
        
        var updatedPrograms = programs
        
        for index in updatedPrograms.indices {
            if let startTime = updatedPrograms[index].event_start_time,
               let formattedStartTime = dateFormatChanger(from: startTime) {
                updatedPrograms[index].event_start_time = formattedStartTime
            } else {
                print("Error formatting start time for event at index \(index)")
            }
            
            if let endTime = updatedPrograms[index].event_end_time,
               let formattedEndTime = dateFormatChanger(from: endTime) {
                updatedPrograms[index].event_end_time = formattedEndTime
            } else {
                print("Error formatting end time for event at index \(index)")
            }
        }
        
        self.programs = updatedPrograms
    }
    
    private func dateFormatChanger(from iso8601String: String) -> String? {
        let isoformatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "d일(E) HH:mm"
        
        isoformatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoformatter.date(from: iso8601String) else {
            print("Error from here: \(iso8601String)")
            return nil
        }
        
        return outputFormatter.string(from: date)
    }
    
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
        
        print("All events cleared")
    }
}
