//
//  ScheduleView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ScheduleView: View {
    @State private var showCalendarView: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                if showCalendarView {
                    CalendarView()
                } else {
                    TimelineView()
                }
            }
            .navigationTitle(showCalendarView ? "캘린더 보기" : "타임라인 보기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            showCalendarView.toggle()
                        }) {
                            Image(systemName: showCalendarView ? "calendar" : "calendar.day.timeline.left")
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    ScheduleView()
}
