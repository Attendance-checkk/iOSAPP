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
    
    let events = [
        String(localized: "개회식"),
        String(localized: "프로젝트 발표"),
        String(localized: "졸업생 토크 콘서트\n[장경호]"),
        String(localized: "졸업생 토크 콘서트\n[전시온]"),
        String(localized: "졸업생 토크 콘서트\n[양태식]"),
        String(localized: "졸업생 토크 콘서트\n[전하윤]"),
        String(localized: "졸업생 토크 콘서트\n[김래훈]"),
        String(localized: "게임 경진대회"),
        String(localized: "폐회식 & 시상식")
    ]
    
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
                
                List(events.indices, id: \.self) { index in
                    NavigationLink(destination: ChecklistDetailView(eventName: events[index], eventLocation: "6129", description: events[index])) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Hello")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(events[index])
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: geometry.size.height, height: geometry.size.height)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            
            .navigationTitle("체크리스트")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func changeProgressTitle() -> String {
        if progress == 1.0 {
            return String(localized: "🥳 스탬프 모으기 완료!")
        } else {
            return String(localized: "학술제 참여하고 경품 받자!")
        }
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
