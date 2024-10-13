//
//  EventView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

struct EventView: View {
    var event: EventStruct
    
    var body: some View {
        VStack {
            Text(event.name)
                .font(.caption)
                .padding(5)
                .background(Color.orange)
                .cornerRadius(10)
                .frame(height: CGFloat(event.duration * 50))
        }
        .padding(2)
    }
}


#Preview {
    EventView(event: EventStruct(name: "Hello", startTime: 9.0, endTime: 13.0))
}
