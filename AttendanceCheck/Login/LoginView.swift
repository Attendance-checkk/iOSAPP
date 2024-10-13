//
//  LoginView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userInformation: UserInformation
    
    @State private var showDepartmentSelection: Bool = false
    @State private var selectedDepartment: String = "학과를 선택하세요"
    @State private var inputStudentID: String = ""
    @State private var inputStudentName: String = ""
    @State private var showAlert: AlertType? = nil
    
    var body: some View {
        NavigationStack {
            if userInformation.loginState {
                MainView()
                    .environmentObject(userInformation)
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut(duration: 0.5), value: userInformation.loginState)
            } else {
                VStack(spacing: 10) {
                    Image("SCHULogo_Rect")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(5)
                    
                    Spacer()
                    
                    Text("학과 선택")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Button(action: {
                        showDepartmentSelection.toggle()
                    }) {
                        HStack {
                            Text(selectedDepartment)
                                .foregroundColor(selectedDepartment == "학과를 선택하세요" ? .gray : .primary)
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    }
                    .sheet(isPresented: $showDepartmentSelection) {
                        DepartmentSelectionView(selectedDepartment: $selectedDepartment)
                    }
                    
                    Text("학번 입력")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 15)
                    TextField("학번", text: $inputStudentID)
                        .padding(20)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                    
                    Text("이름 입력")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 15)
                    TextField("이름", text: $inputStudentName)
                        .padding(20)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    
                    Button(action: {
                        loginButtonClicked()
                    }) {
                        Text("로그인")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 3)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 50)
                    .alert(item: $showAlert) { alert in
                        switch alert {
                        case .success:
                            return Alert(
                                title: Text("로그인 성공"),
                                message: Text("반갑습니다! \(userInformation.studentName ?? "학생")님!"),
                                dismissButton: .default(Text("확인"), action: {
                                    userInformation.loginState = true
                                    userInformation.storedLoginState = true
                                })
                            )
                            
                        case .loginFailed:
                            return Alert(
                                title: Text("로그인 실패"),
                                message: Text("로그인 중 문제가 발생하였습니다! 로그인을 다시 시도해주세요"),
                                dismissButton: .default(Text("확인"))
                            )
                            
                        case .idFormatError:
                            return Alert(
                                title: Text("학번 오류"),
                                message: Text("학번 형식이 올바르지 않습니다"),
                                dismissButton: .default(Text("확인"))
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(30)
                
                .navigationTitle("로그인")
            }
        }
    }
    
    private func loginButtonClicked() {
        if studentIDValidation() {
            userInformation.department = selectedDepartment
            userInformation.studentID = inputStudentID
            userInformation.studentName = inputStudentName
            
            userInformation.login { success in
                if success {
                    showAlert = .success
                } else {
                    showAlert = .loginFailed
                }
            }
        } else {
            showAlert = .idFormatError
        }
        
        print("Saved User Information: \(String(describing: userInformation.department)), \(String(describing: userInformation.studentID)), \(String(describing: userInformation.studentName))")
    }
    
    private func studentIDValidation() -> Bool {
        return inputStudentID.count == 8
    }
}

#Preview {
    LoginView()
}
