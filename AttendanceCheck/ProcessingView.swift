//
//  ProcessingView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/14/24.
//

import SwiftUI

struct ProcessingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                Text("처리 중입니다...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            
        }
    }
}

#Preview {
    ProcessingView()
}
