//
//  CalendarView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var programs: [Events]? = nil
    
    var body: some View {
        Text("Hello, World!")
        
//        ScrollView {
//            VStack {
//                ForEach(0..<24) { hour in
//                    HStack(alignment: .top) {
//                        let timeString: String = ""
//                        if hour < 10 { timeString = "0\(hour):00" } else { timeString = "\(hour):00" }
//                        
//                        Text(timeString)
//                            .frame(width: 50)
//                            .padding(.leading)
//                        
//                        ZStack {
//                            Rectangle()
//                                .stroke(Color.gray, lineWidth: 1)
//                                .frame(height: 50)
//                                .background(Color.clear)
//                            
//                            if let programs = programs {
//                                ForEach(programs.events) { event in
//                                    
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private func isEventInHour(event: Program, hour: Int) -> Bool {
//        guard let startTime = event.startTime, let endTime = event.endTime else { return false }
//        
//        let calendar = Calendar.current
//        let eventStartHour = calendar.component(.hour, from: startTime)
//        let eventEndHour = calendar.component(.hour, from: endTime)
//        
//        return hour >= eventStartHour && hour <= eventEndHour
//    }
//    
//    private func loadProgramsData() {
//        if let loadedPrograms = loadPrograms(from: "Programs") {
//            programs = loadedPrograms
//        } else {
//            print("Failed to load programs")
//        }
//    }
//    
//    private func loadPrograms(from fileName: String) -> Programs? {
//        
//        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
//            print("Cannot find JSON file: \(fileName).json")
//            return nil
//        }
//        
//        do {
//            let data = try Data(contentsOf: url)
//            let programs = try JSONDecoder().decode(Programs.self, from: data)
//            return programs
//        } catch {
//            print("JSON decoding error: \(error.localizedDescription)")
//            return nil
//        }
    }
}

#Preview {
    CalendarView()
}
