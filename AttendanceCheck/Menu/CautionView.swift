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
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("계정은 한 번 삭제하면 복구할 수 없습니다.\n계정 삭제 옵션은 개인정보(학과, 학번, 이름)를 잘못 입력하신 경우에만 사용해주시기 바랍니다.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                showAlert = true
            }) {
                Text("계정 삭제")
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width / 3)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("계정 삭제"),
                      message: Text("정말로 삭제하시겠습니까? 계정은 다시 복구되지 않습니다."),
                      primaryButton: .destructive(Text("삭제")) {
                    eventManager.clearEventManager()
                    userInformation.userDelete()
                    userInformation.clearUserInformation()
                },
                      secondaryButton: .cancel()
                )
            }
            
            .navigationTitle("계정 삭제 주의사항")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
}

#Preview {
    CautionView()
}
