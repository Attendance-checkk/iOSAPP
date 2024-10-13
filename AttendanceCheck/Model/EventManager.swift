//
//  EventManager.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/12/24.
//

import SwiftUI

class EventManager: ObservableObject {
    @AppStorage("completedEvents") var completedEvents: String = ""
    
    @AppStorage("event1") var event1: Bool = false
    @AppStorage("event2") var event2: Bool = false
    @AppStorage("event3") var event3: Bool = false
    @AppStorage("event4") var event4: Bool = false
    @AppStorage("event5") var event5: Bool = false
    @AppStorage("event6") var event6: Bool = false
    @AppStorage("event7") var event7: Bool = false
    @AppStorage("event8") var event8: Bool = false
    @AppStorage("event9") var event9: Bool = false
    
    @AppStorage("progress") var progress: Double = 0.0
    @Published var programs: Programs? = nil
    @Published var isLoading: Bool = true
    
    init() {
        loadProgramsData()
    }
    
    public func isEventCompleted(index: Int) -> Bool {
        print("isEventComplete function called: \(index)")
        
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
    
    public func completeEventByQRCode(_ qrcode: String) {
        print("completeEventByQRCode function called: \(qrcode)")
        
        guard let programs = programs else { return }
        
        for (index, event) in programs.events.enumerated() {
            if event.qrString == qrcode {
                switch index {
                case 0:
                    if !event1 {
                        event1 = true
                        calculateProgress()
                    }
                case 1:
                    if !event2 {
                        event2 = true
                        calculateProgress()
                    }
                case 2...6:
                    if !event3 && index == 2 {
                        event3 = true
                        calculateProgress()
                    } else if !event4 && index == 3 {
                        event4 = true
                        calculateProgress()
                    } else if !event5 && index == 4 {
                        event5 = true
                        calculateProgress()
                    } else if !event6 && index == 5 {
                        event6 = true
                        calculateProgress()
                    } else if !event7 && index == 6 {
                        event7 = true
                        calculateProgress()
                    }
                case 7:
                    if !event8 {
                        event8 = true
                        calculateProgress()
                    }
                case 8:
                    if !event9 {
                        event9 = true
                        calculateProgress()
                    }
                default:
                    print("Unknown QR code: \(qrcode)")
                    break
                }
            }
        }
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
    
    public func loadProgramsData() {
        if let loadedPrograms = loadPrograms(from: "Programs") {
            programs = loadedPrograms
            
            isLoading = false
        } else {
            print("Failed to load programs")
        }
    }
    
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
