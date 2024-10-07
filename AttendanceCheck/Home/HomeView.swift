//
//  HomeView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct HomeView: View {
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
    
    let gridItems = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("학술제 참여하고 경품 받자!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.horizontal, 20)
                
                LazyVGrid(columns: gridItems, spacing: 10) {
                    ForEach(events.indices, id: \.self) { index in
                        NavigationLink(destination: ChecklistDetailView(eventName: events[index], eventLocation: "6129", description: events[index])) {
                            GeometryReader { geometry in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                    
                                    Text(events[index])
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .multilineTextAlignment(.center)
                                    
                                    if completedEvenets.contains(index) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.green)
                                            .offset(x: geometry.size.width / 3, y: -geometry.size.width / 3)
                                    }
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .padding(20)
            }
            
            .navigationTitle("체크리스트")
            .navigationBarTitleDisplayMode(.inline)
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
    HomeView()
}
