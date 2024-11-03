//
//  AccountAlertView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 11/3/24.
//

import SwiftUI

struct AccountAlertView: View {
    @State var showAccountAlert: Bool = false
    @EnvironmentObject var userInformation: UserInformation
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showWebView: Bool = false
    
    let faqURL: String = LinkURLS.faqURL.url
    
    var statusCode: Int
    var message: String
    
    var body: some View {
        VStack {
            Text("⚠️ 계정 오류")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
            
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
                    Text("◀️ 로그아웃")
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
        .alert(isPresented: $showAccountAlert) {
            Alert(
                title: Text("로그아웃되었습니다"),
                dismissButton: .default(Text("확인")) {
                    userInformation.loginState = false
                    userInformation.storedLoginState = false
                    
                    dismissView()
                }
            )
        }
        
        .sheet(isPresented: $showWebView) {
            WebView(urlString: faqURL)
        }
    }
    
    private func logOut() {
        showAccountAlert = true
    }
    
    func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}
