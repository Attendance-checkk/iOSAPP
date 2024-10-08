//
//  LoginView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct LoginView: View {
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10, content: {
                
                
                TextField("학번", text: .constant(""))
                    .padding(20)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                
                TextField("이름", text: .constant(""))
                    .padding(20)
                    .background(Color.gray.opacity(0.5))
                    .cornerRadius(10)
                
            })
            
                .navigationTitle("로그인")
        }
    }
}

#Preview {
    LoginView()
}
