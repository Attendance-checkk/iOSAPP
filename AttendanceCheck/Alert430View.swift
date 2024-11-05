//
//  Alert430View.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import SwiftUI

struct Alert430View: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showWebView: Bool = false
    
    let faqURL: String = LinkURLS.faqURL.url
    
    var statusCode: Int = 430
    var title: String = "⚠️ 서버 요청 횟수 초과"
    var message: String = "서버 요청 횟수가 초과되었습니다./n잠시 후 다시 사용 가능합니다."
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            HStack {
                Text(message)
                    .font(.headline)
                    .padding()
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.primary)
                
                Spacer()
            }
            .padding(.top, 15)
            .padding(.horizontal, 15)
            
            Spacer()
            
            HStack {
                Button(action: {
                    logOut()
                }) {
                    Text("◀️ 뒤로가기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 3)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                
                Spacer()
                
                Button(action: {
                    showWebView = true
                }) {
                    Text("🙋 문의하기")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 3)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
        }
        
        .sheet(isPresented: $showWebView) {
            WebView(urlString: faqURL)
        }
    }
    
    private func logOut() {
        dismissView()
    }
    
    func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}
