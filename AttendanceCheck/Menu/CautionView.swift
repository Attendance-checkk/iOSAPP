//
//  CautionView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/18/24.
//

import SwiftUI

struct CautionView: View {
    @EnvironmentObject private var eventManager: EventManager
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var notificationManager: NotificationManager
    
    @State private var showWebView: Bool = false
    @State private var showAlert: Bool = false
    
    let faqURL: String = LinkURLS.faqURL.url
    let cautionString: String = """
계정은 한 번 삭제하면 복구할 수 없습니다.
계정 삭제 옵션은 개인정보(학과, 학번, 이름)를 잘못 입력하신 경우에만 사용해 주시기 바랍니다.
로그아웃 기능은 악용될 소지가 있어 제공하지 않습니다.

관리자와 상의 없이 계정을 삭제하신 경우, 참가가 가능한 시간이 지난 이벤트의 스탬프는 다시 찍어 드릴 수 없습니다.
따라서 학생 여러분께서는 계정에 문제가 있으실 경우, 계정을 삭제하시기 전에 반드시 관리자에게 문의하시기 바랍니다.
"""
    
    var body: some View {
        VStack {
            HStack {
                Text(cautionString)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button(action: {
                    showAlert = true
                }) {
                    Text("🗑️ 계정삭제")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: UIScreen.main.bounds.width / 3)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("계정 삭제"),
                          message: Text("정말로 삭제하시겠습니까? 계정은 다시 복구되지 않습니다."),
                          primaryButton: .destructive(Text("삭제")) {
                        eventManager.clearEventManager()
                        userInformation.userDelete()
                    },
                          secondaryButton: .cancel()
                    )
                }
                
                Spacer()
                
                Button(action: {
                    showWebView = true
                }) {
                    HStack {
                        Text("🙋 문의하기")
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
            
            .sheet(isPresented: $showWebView) {
                WebView(urlString: faqURL)
            }
            
            .navigationTitle("계정 삭제 주의사항")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
}

#Preview {
    CautionView()
}
