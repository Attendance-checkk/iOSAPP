//
//  LoginView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    
    enum Field: Hashable {
        case studentID
        case studentName
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var showDepartmentSelection: Bool = false
    @State private var selectedDepartment: String = "학과를 선택하세요"
    @State private var inputStudentID: String = ""
    @State private var inputStudentName: String = ""
    @State private var showAlert: AlertType? = nil
    @State private var isLoading: Bool = false
    
    @State private var departmentFormatErrorString: String = "헉과 선택"
    @State private var departmentFormatErrorColor: Color = .primary
    
    @State private var studentIDFormatErrorString: String = "학번 입력"
    @State private var studentIDFormatErrorColor: Color = .primary
    
    @State private var studentNameFormatErrorString: String = "이름 입력"
    @State private var studentNameFormatErrorColor: Color = .primary
    
    @State private var studentIDValidationResult: Bool = false
    
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
                ZStack {
                    if colorScheme == .light {
                        Color.white
                            .ignoresSafeArea()
                            .onTapGesture {
                                focusedField = nil
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    } else {
                        Color.black
                            .ignoresSafeArea()
                            .onTapGesture {
                                focusedField = nil
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                    }
                    VStack(spacing: 10) {
                        Spacer()
                        
                        Text("👋 환영합니다!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Image("SCHULogo_Rect")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                        
                        HStack {
                            Text(departmentFormatErrorString)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(departmentFormatErrorColor)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                        
                        Menu {
                            Button {
                                selectedDepartment = "사물인터넷학과"
                                departmentFormatValidation()
                            } label: {
                                Text("사물인터넷학과")
                            }
                            Button {
                                selectedDepartment = "의료IT공학과"
                                departmentFormatValidation()
                            } label: {
                                Text("의료IT공학과")
                            }
                            Button {
                                selectedDepartment = "AI∙빅데이터학과"
                                departmentFormatValidation()
                            } label: {
                                Text("AI∙빅데이터학과")
                            }
                            Button {
                                selectedDepartment = "정보보호학과"
                                departmentFormatValidation()
                            } label: {
                                Text("정보보호학과")
                            }
                            Button {
                                selectedDepartment = "컴퓨터소프트웨어공학과"
                                departmentFormatValidation()
                            } label: {
                                Text("컴퓨터소프트웨어공학과")
                            }
                            Button {
                                selectedDepartment = "메타버스&게임학과"
                                departmentFormatValidation()
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
                            Text(studentIDFormatErrorString)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(studentIDFormatErrorColor)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 15)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                        TextField("학번", text: $inputStudentID)
                            .padding(20)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                            .onChange(of: inputStudentID) { _ in
                                studentIDFormatValidation()
                            }
                            .onSubmit {
                                focusedField = .studentName
                            }
                        
                        HStack {
                            Text(studentNameFormatErrorString)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(studentNameFormatErrorColor)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 15)
                            
                            Spacer()
                        }
                        .padding(.leading, 10)
                        TextField("이름", text: $inputStudentName)
                            .padding(20)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                            .focused($focusedField, equals: .studentName)
                            .submitLabel(.done)
                            .onChange(of: inputStudentName, perform: { _ in
                                studentNameFormatValidation()
                            })
                            .onSubmit {
                                loginButtonClicked()
                            }
                        
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
                                    message: Text("로그인 중 문제가 발생하였습니다! 입력 내용을 확인해주세요!"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .noIDError:
                                return Alert(
                                    title: Text("학번 없음"),
                                    message: Text("학번을 입력해주세요!"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .idFormatError:
                                return Alert(
                                    title: Text("학번 오류"),
                                    message: Text("학번 형식이 올바르지 않습니다"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .noDepartmentError:
                                return Alert(
                                    title: Text("학과 없음"),
                                    message: Text("학과를 선택해주세요!"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .departmentFormatError:
                                return Alert(
                                    title: Text("학과 오류"),
                                    message: Text("학과를 선택해주세요!"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .noNameError:
                                return Alert(
                                    title: Text("이름 없음"),
                                    message: Text("이름을 입력해주세요!"),
                                    dismissButton: .default(Text("확인"))
                                )
                                
                            case .nameFormatError:
                                return Alert(
                                    title: Text("이름 오류"),
                                    message: Text("이름 형식이 올바르지 않습니다"),
                                    dismissButton: .default(Text("확인"))
                                )
                            
                            case .recheck:
                                return Alert(
                                    title: Text("입력 정보 확인"),
                                    message: Text("입력한 정보가 맞으신가요?\n입력 정보가 다르다면 경품지급이 어려울 수 있습니다!"),
                                    primaryButton: .default(Text("로그인"), action: {
                                        isLoading = true
                                        
                                        userInformation.department = selectedDepartment
                                        userInformation.studentID = inputStudentID
                                        userInformation.studentName = inputStudentName
                                        
                                        userInformation.login { success in
                                            self.isLoading = false
                                            if success {
                                                eventManager.loadProgramsData { success, statusCode, message in
                                                    showAlert = .success
                                                }
                                            } else {
                                                showAlert = .loginFailed
                                            }
                                        }
                                    }),
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(30)
    }
    
    private func departmentFormatValidation() -> Bool {
        let noSelectBool: Bool = selectedDepartment != "학과를 선택하세요"
        
        if noSelectBool {
            departmentFormatErrorString = "학과가 선택되었습니다"
            departmentFormatErrorColor = .green
            return true
        } else {
            departmentFormatErrorString = "학과를 선택해주세요"
            departmentFormatErrorColor = .red
            return false
        }
    }
    
    private func studentIDFormatValidation() -> Bool {
        let emptyBool: Bool = !inputStudentID.isEmpty
        let lengthBool: Bool = inputStudentID.count == 8
        let prefixBool: Bool = inputStudentID.hasPrefix("20")
        let onlyNumberBool: Bool = inputStudentID.allSatisfy(\.isNumber)
        
        print("emptyBool: \(emptyBool), lengthBool: \(lengthBool), prefixBool: \(prefixBool), onlyNumberBool: \(onlyNumberBool)")
        
        if emptyBool && lengthBool && prefixBool && onlyNumberBool {
            studentIDFormatErrorString = "학번이 적절한 형식입니다"
            studentIDFormatErrorColor = .green
            return true // 형식이 올바른 경우
        } else {
            studentIDFormatErrorString = "학번 형식이 올바르지 않습니다"
            studentIDFormatErrorColor = .red
            return false // 형식이 올바르지 않은 경우
        }
    }
    
    private func studentNameFormatValidation() -> Bool {
        let emptyBool: Bool = !inputStudentName.isEmpty
        let atLeast2Bool: Bool = inputStudentName.count >= 2
        let placeholderBool: Bool = inputStudentName != "이름"
        let containsNumber: Bool = inputStudentName.rangeOfCharacter(from: .decimalDigits) != nil
        let containsSpecialCharacter: Bool = inputStudentName.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil || inputStudentName.rangeOfCharacter(from: CharacterSet.symbols) != nil
        
        print("emptyBool: \(emptyBool), atLeast2Bool: \(atLeast2Bool), placeholderBool: \(placeholderBool), containsNumber: \(containsNumber), containsSpecialCharacter: \(containsSpecialCharacter)")

        if emptyBool && placeholderBool && !containsNumber && !containsSpecialCharacter && atLeast2Bool {
            studentNameFormatErrorString = "이름이 적절한 형식입니다"
            studentNameFormatErrorColor = .green
            return true
        } else {
            studentNameFormatErrorString = "이름 형식이 올바르지 않습니다"
            studentNameFormatErrorColor = .red
            return false
        }
    }

    
    private func deviceSpecificImageWidth() -> CGFloat {
        print(UIScreen.main.bounds.width)
        
        let model = UIDevice.current.modelName
        
        switch model {
        case "iPhone12,1": // iPhone 11
            return 250
        case "iPhone12,3": // iPhone 11 Pro
            return 300
        case "iPhone12,5": // iPhone 11 Pro Max
            return 350
        case "iPhone12,8": // iPhone SE 2nd Gen
            return 200
        case "iPhone13,1": // iPhone 12 Mini
            return 250
        case "iPhone13,2": // iPhone 12
            return 300
        case "iPhone13,3": // iPhone 12 Pro
            return 300
        case "iPhone13,4": // iPhone 12 Pro Max
            return 350
        case "iPhone14,2": // iPhone 13 Pro
            return 300
        case "iPhone14,3": // iPhone 13 Pro Max
            return 350
        case "iPhone14,4": // iPhone 13 Mini
            return 250
        case "iPhone14,5": // iPhone 13
            return 300
        case "iPhone14,6": // iPhone SE 3rd Gen
            return 200
        case "iPhone14,7": // iPhone 14
            return 300
        case "iPhone14,8": // iPhone 14 Plus
            return 350
        case "iPhone15,2": // iPhone 14 Pro
            return 350
        case "iPhone15,3": // iPhone 14 Pro Max
            return 400
        case "iPhone15,4": // iPhone 15
            return 350
        case "iPhone15,5": // iPhone 15 Plus
            return 400
        case "iPhone16,1": // iPhone 15 Pro
            return 380
        case "iPhone16,2": // iPhone 15 Pro Max
            return 400
        case "iPhone17,1": // iPhone 16 Pro
            return 380
        case "iPhone17,2": // iPhone 16 Pro Max
            return 400
        case "iPhone17,3": // iPhone 16
            return 350
        case "iPhone17,4": // iPhone 16 Plus
            return 400
        default:
            return 300 // 기본값
        }
    }
    
    private func loginButtonClicked() {
        if !departmentFormatValidation() {
            showAlert = .departmentFormatError
            return
        }
        
        if !studentIDFormatValidation() {
            showAlert = .idFormatError
            return
        }
            
        if !studentNameFormatValidation() {
            showAlert = .nameFormatError
            return
        }
        
        showAlert = .recheck
        
        print("Saved User Information: \(String(describing: userInformation.department)), \(String(describing: userInformation.studentID)), \(String(describing: userInformation.studentName))")
    }
}

#Preview {
    LoginView()
}
