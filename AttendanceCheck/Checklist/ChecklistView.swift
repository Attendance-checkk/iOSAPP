//
//  ChecklistView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct ChecklistView: View {
    @State private var progress: Double = 0.0
    @State private var completedEvenets: Set<Int> = []
    @State private var programs: Programs? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(changeProgressTitle())
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 20)
                
                if let events = programs?.events {
                    List(events.indices, id: \.self) { index in
                        NavigationLink(destination: detailView(for: index)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Hello")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(events[index].title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                
                                GeometryReader { geometry in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: geometry.size.height, height: geometry.size.height)
                                            .foregroundColor(.white)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.black, lineWidth: 1)
                                            }
                                        
                                        Image("SCHUCSTAMP")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.height * 0.9, height: geometry.size.height * 0.9)
                                            .opacity(completedEvenets.contains(index) ? 1.0 : 0.0)
                                    }
                                }
                                .frame(width: 50, height: 50)
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
            }
            
            .navigationTitle("체크리스트")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadProgramsData()
            }
        }
    }
    
    private func detailView(for index: Int) -> some View {
        let title: String = programs?.events[index].title ?? "TitleStringError"
        let location: String = programs?.events[index].location ?? "LocationStringError"
        let description: String = programs?.events[index].descriptionString ?? "DescriptionStringError"
        
        return ChecklistDetailView(eventName: title, eventLocation: location, description: description)
    }
    
    private func loadProgramsData() {
        if let loadedPrograms = loadPrograms(from: "Programs") {
            programs = loadedPrograms
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
    
    private func changeProgressTitle() -> String {
        return progress == 1.0 ? "🥳 스탬프 모으기 완료!" : "학술제 참여하고 경품 받자!"
    }
    
    private func calcuateProgress() {
        var newProgress: Double = 0.0
        
        if completedEvenets.contains(0) { newProgress += 0.2 }
        if completedEvenets.contains(1) { newProgress += 0.2 }
        if completedEvenets.contains(2...6) { newProgress += 0.2 }
        if completedEvenets.contains(7) { newProgress += 0.2 }
        if completedEvenets.contains(8) { newProgress += 0.2 }
        
        progress = newProgress
    }
    
    private func completeEvent(index: Int) {
        if !completedEvenets.contains(index) {
            completedEvenets.insert(index)
            
            calcuateProgress()
        }
    }
}

#Preview {
    ChecklistView()
}
