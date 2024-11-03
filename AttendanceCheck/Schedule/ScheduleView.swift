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
            ZStack {
                VStack {
                    if showCalendarView {
                        CalendarView()
                            .transition(.scale)
                    } else {
                        ZStack {
                            TimelineView()
                                .transition(.scale)
                        }
                    }
                }
                .animation(.easeInOut, value: showCalendarView)
                .navigationTitle(showCalendarView ? "캘린더" : "타임라인")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    showCalendarView.toggle()
                                }
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
}

#Preview {
    ScheduleView()
}
