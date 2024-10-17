//
//  LoginView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    
    @State private var showDepartmentSelection: Bool = false
    @State private var selectedDepartment: String = "학과를 선택하세요"
    @State private var inputStudentID: String = ""
    @State private var inputStudentName: String = ""
    @State private var showAlert: AlertType? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            if isLoading {
                ProcessingView(messageString: "로그인 중입니다..")
                    .transition(.opacity)
            } else if userInformation.loginState {
                MainView()
                    .environmentObject(userInformation)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1), value: userInformation.loginState)
                    .onAppear {
                        eventManager.changeDateFormat()
                    }
            } else {
                VStack(spacing: 10) {
                    Spacer()
                    
                    Text("🎉 SW융합대학 첫 학술제에 오신 걸 환영해요! 🎉")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Image("SCHULogo_Rect")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .padding(.vertical, 40)
                    
                    HStack {
                        Text("학과 선택")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                    
                    Menu {
                        Button {
                            selectedDepartment = "사물인터넷학과"
                        } label: {
                            Text("사물인터넷학과")
                        }
                        Button {
                            selectedDepartment = "의료IT공학과"
                        } label: {
                            Text("의료IT공학과")
                        }
                        Button {
                            selectedDepartment = "AI∙빅데이터학과"
                        } label: {
                            Text("AI∙빅데이터학과")
                        }
                        Button {
                            selectedDepartment = "정보보호학과"
                        } label: {
                            Text("정보보호학과")
                        }
                        Button {
                            selectedDepartment = "컴퓨터소프트웨어공학과"
                        } label: {
                            Text("컴퓨터소프트웨어공학과")
                        }
                        Button {
                            selectedDepartment = "메타버스&게임학과"
                        } label: {
                            Text("메타버스&게임학과")
                        }
                    } label: {
                        HStack {
                            Text(selectedDepartment)
                                .foregroundColor(selectedDepartment == "학과를 선택하세요" ? .gray : .primary)
                            Spacer()
                        }
                        .padding(20)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("학번 입력")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 15)
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
                    TextField("학번", text: $inputStudentID)
                        .padding(20)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        Text("이름 입력")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 15)
                        
                        Spacer()
                    }
                    .padding(.leading, 20)
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
            }
        }
    }
    
    private func loginButtonClicked() {
        if studentIDValidation() {
            isLoading = true
            
            userInformation.department = selectedDepartment
            userInformation.studentID = inputStudentID
            userInformation.studentName = inputStudentName
            
            userInformation.login { success in
                if success {
                    eventManager.loadProgramsData { success in
                        isLoading = false
                        showAlert = .success
                    }
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
