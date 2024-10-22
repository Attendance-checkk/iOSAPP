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
        "SCHUSWCU1stAF_TalkConcertwithGraduatedStudent": 2,
        "SCHUSWCU1stAF_SWCUGameContest": 3,
        "SCHUSWCU1stAF_IndustryExpertSpecialLecture": 4
    ]
    
    @Published var event1: Bool = false
    @Published var event2: Bool = false
    @Published var event3: Bool = false
    @Published var event4: Bool = false
    @Published var event5: Bool = false
    @Published var progress: Double = 0.0
    
    @Published var programs: [Events]? = nil
    
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
        default: return false
        }
    }
    
    // MARK: - API(POST event code to server) 01(External)
    public func completeEventByQRCode(_ qrcode: String, completion: @escaping(Bool, Int?, String?) -> Void) {
        print("completeEventByQRCode function called: \(qrcode)")
        
        
        eventPost(qrcode) { success, statusCode, message in
            DispatchQueue.main.async {
                
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
        
        let token = userInformation.accessToken
        
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
        if event3 { newProgress += 0.2 }
        if event4 { newProgress += 0.2 }
        if event5 { newProgress += 0.2 }
        
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
        
        loadPrograms { success, statusCode, message in
            DispatchQueue.main.async {
                
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
        guard let fileURL = Bundle.main.url(forResource: "Programs", withExtension: "json") else {
                    print("Programs.json 파일을 찾을 수 없습니다.")
                    return
                }

                do {
                    // 파일에서 데이터 읽어오기
                    let data = try Data(contentsOf: fileURL)
                    
                    // JSON 디코딩
                    let decoder = JSONDecoder()
                    let loadedPrograms = try decoder.decode([Events].self, from: data)
                    
                    // 프로그램 리스트 업데이트
                    self.programs = loadedPrograms
                    changeDateFormat()
                    print("Programs 데이터를 성공적으로 불러왔습니다.")
                } catch {
                    print("Programs 데이터를 로드하는 도중 오류 발생: \(error)")
                }
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
        
        isoformatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoformatter.date(from: iso8601String) else {
            print("Error from here: \(iso8601String)")
            return nil
        }
        
        if is12HourFormat() {
            outputFormatter.dateFormat = "MM월 d일(E) a h:mm"
        } else {
            outputFormatter.dateFormat = "MM월 d일(E) HH:mm"
        }
        
        return outputFormatter.string(from: date)
    }
    
    public func is12HourFormat() -> Bool {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        
        let timeFormat = formatter.dateFormat ?? ""
        return timeFormat.contains("a")
    }
    
    public func clearEventManager() {
        event1 = false
        event2 = false
        event3 = false
        event4 = false
        event5 = false
        progress = 0.0
        
        print("All events cleared")
    }
    
    public func returnProgramsForTimeline() -> [Events] {
        var timelinePrograms = programs ?? []
        
        timelinePrograms.append(Events(
            event_code: "SCHUSWCU1stAF_ClosingCeremony",
            event_name: "폐회식 및 시상식",
            description: "학술제에 마지막까지 함께해주세요!\n시상식이 끝난 후 이벤트에 모두 참여하신 분께는 경품 추첨의 기회가 주어집니다\n1등의 주인공이 되어보세요!",
            location: "인문과학관 1층 대강당 [6129호]",
            event_start_time: dateFormatChanger(from: "2024-11-06T06:00:00.000Z"),
            event_end_time: dateFormatChanger(from: "2024-11-06T07:30:00.000Z"),
            createdAt: "2024-10-18T04:18:16.000Z"
        ))
        
        return timelinePrograms
    }
    
    public func returnProgramsForChecklist() -> [Events] {
        let timelinePrograms = programs ?? []
        
        return timelinePrograms
    }
}

