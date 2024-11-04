//
//  LoginView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import Foundation
import SwiftUI
import Security

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    enum Field: Hashable {
        case studentID
        case studentName
        case password
        case passwordCheck
    }
    
    @FocusState private var focusedField: Field?
    
    @State private var showDepartmentSelection: Bool = false
    @State private var selectedDepartment: String = "학과를 선택하세요"
    @State private var inputStudentID: String = ""
    @State private var inputStudentName: String = ""
    @State private var inputPassword: String = ""
    @State private var inputPasswordAgain: String = ""
    @State private var showAlert: AlertType? = nil
    @State private var isLoginLoading: Bool = false
    
    @State private var departmentFormatErrorString: String = "학과 선택"
    @State private var departmentFormatErrorColor: Color = .primary
    
    @State private var studentIDFormatErrorString: String = "학번 입력"
    @State private var studentIDFormatErrorColor: Color = .primary
    
    @State private var studentNameFormatErrorString: String = "이름 입력"
    @State private var studentNameFormatErrorColor: Color = .primary
    
    @State private var passwordCheckString: String = "비밀번호"
    @State private var passwordCheckColor: Color = .primary
    @State private var showPasswordButton: Bool = false
    
    @State private var passwordDifferentString: String = "비밀번호 재확인"
    @State private var passwordDifferentColor: Color = .primary
    
    @State private var studentIDValidationResult: Bool = false
    
    @State private var showWebView: Bool = false
    let faqURL = LinkURLS.faqURL.url
    
    var body: some View {
        NavigationStack {
            if isLoginLoading {
                ProcessingView(messageString: "로그인 중입니다..")
                    .transition(.opacity)
            } else if userInformation.loginState {
                MainView()
                    .environmentObject(userInformation)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1), value: userInformation.loginState)
                    .onAppear {
                        eventManager.changeDateFormat() {
                            
                        }
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
                    ScrollView {
                        VStack(spacing: 20) {
                            Image("SCHULogo_Rect")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            
                            HStack {
                                Text(departmentFormatErrorString)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(departmentFormatErrorColor)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                            .padding(.bottom, -5)
                            
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
                                    .padding(.bottom, -5)
                                
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
                                    .padding(.bottom, -5)
                                
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
                                    focusedField = .password
                                }
                            
                            // MARK: - 비밀번호 입력 파트
                            HStack {
                                Text(passwordCheckString)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(passwordCheckColor)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, -5)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                            
                            ZStack {
                                if showPasswordButton {
                                    TextField("비밀번호를 입력해주세요", text: $inputPassword)
                                        .padding(20)
                                        .background(Color.gray.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .focused($focusedField, equals: .password)
                                        .keyboardType(.asciiCapable)
                                        .autocorrectionDisabled(true)
                                        .onAppear {
                                            if let password = getPassword(service: "KyeonghoJang.AttendanceCheck", account: inputStudentID) {
                                                inputPassword = password
                                            }
                                        }
                                        .onChange(of: inputPassword) { _ in
                                            passwordFormatIsWrong()
                                        }
                                        .onSubmit {
                                            if isPasswordDifferentError() {
                                                loginButtonClicked()
                                            } else {
                                                focusedField = .passwordCheck
                                            }
                                        }
                                } else {
                                    SecureField("비밀번호를 입력해주세요", text: $inputPassword)
                                        .padding(20)
                                        .background(Color.gray.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .focused($focusedField, equals: .password)
                                        .keyboardType(.asciiCapable)
                                        .autocorrectionDisabled(true)
                                        .onAppear {
                                            if let password = getPassword(service: "KyeonghoJang.AttendanceCheck", account: inputStudentID) {
                                                inputPassword = password
                                            }
                                        }
                                        .onChange(of: inputPassword) { _ in
                                            passwordFormatIsWrong()
                                            passwordCheckIsDifferent()
                                        }
                                        .onSubmit {
                                            if isPasswordDifferentError() {
                                                loginButtonClicked()
                                            } else {
                                                focusedField = .passwordCheck
                                            }
                                        }
                                }

                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showPasswordButton.toggle()
                                    }) {
                                        Image(systemName: showPasswordButton ? "eye.slash" : "eye")
                                            .foregroundColor(.blue)
                                            .padding(.trailing, 20)
                                    }
                                }
                            }
                            
                            HStack {
                                Text("대∙소∙특수문자/숫자 포함 8자리 이상 작성해주세요!")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding(.top, -15)
                            .padding(.leading, 10)
                            
                            // MARK: - 비밀번호 확인용
                            HStack {
                                Text(passwordDifferentString)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(passwordDifferentColor)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, -5)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                            
                            SecureField("비밀번호를 재입력해주세요", text: $inputPasswordAgain)
                                .padding(20)
                                .background(Color.gray.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .focused($focusedField, equals: .passwordCheck)
                                .keyboardType(.asciiCapable)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .onChange(of: inputPasswordAgain) { _ in
                                    passwordFormatIsWrong()
                                    passwordCheckIsDifferent()
                                }
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
                            .padding(.top, 30)
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
                                    return returnAlert("로그인 실패", "로그인 중 문제가 발생하였습니다! 입력 내용을 확인해주세요!")
                                    
                                case .noIDError:
                                    return returnAlert("학번 없음", "학번을 입력해주세요!")
                                    
                                case .idFormatError:
                                    return returnAlert("학번 오류", "학번 형식이 올바르지 않습니다")
                                    
                                case .noDepartmentError:
                                    return returnAlert("학과 없음", "학과를 선택해주세요!")
                                    
                                case .departmentFormatError:
                                    return returnAlert("학과 오류", "학과를 선택해주세요!")
                                    
                                case .noNameError:
                                    return returnAlert("이름 없음", "이름을 입력해주세요!")
                                    
                                case .nameFormatError:
                                    return returnAlert("이름 오류", "이름 형식이 올바르지 않습니다")
                                    
                                case .noPasswordError:
                                    return returnAlert("비밀번호 없음", "비밀번호를 입력해주세요!")
                                    
                                case .passwordFormatError:
                                    return returnAlert("비밀번호 형식 오류", "비밀번호 형식이 올바르지 않습니다")
                                    
                                case .passwordDifferentError:
                                    return returnAlert("비밀번호가 다릅니다", "비밀번호를 다시 한 번 확인해주세요")
                                
                                case .recheck:
                                    return Alert(
                                        title: Text("입력 정보 확인"),
                                        message: Text("입력한 정보가 맞으신가요?\n입력 정보가 다를 시 불이익이 있을 수 있습니다!"),
                                        primaryButton: .default(Text("로그인"), action: {
                                            isLoginLoading = true
                                            
                                            userInformation.department = selectedDepartment
                                            userInformation.studentID = inputStudentID
                                            userInformation.studentName = inputStudentName
                                            
                                            // MARK: - 비밀번호 저장
                                            
                                            userInformation.login { success, statusCode, message in
                                                self.isLoginLoading = false
                                                if statusCode == 200 {
                                                    eventManager.loadProgramsData { success, statusCode, message in
                                                        showAlert = .success
                                                    }
                                                }
                                                else if statusCode == 408 {
                                                    showAlert = .alreadyRegistered
                                                } else if statusCode == 405 {
                                                    showAlert = .savedPasswordDifferentError
                                                } else if statusCode == 406 {
                                                    showAlert = .userInformationDifferentError
                                                } else if statusCode == 500 {
                                                    showAlert = .networkError
                                                } else if statusCode == 429 {
                                                    showAlert = .tooManyLoginRequests
                                                } else if statusCode == 430 {
                                                    showAlert = .tooManyAPIRequests
                                                } else {
                                                    showAlert = .loginFailed
                                                }
                                            }
                                        }),
                                        secondaryButton: .cancel()
                                    )
                                    
                                case .alreadyRegistered:
                                    return returnAlert("이미 등록된 학생", "이미 등록된 학생입니다!")
                                    
                                case .savedPasswordDifferentError:
                                    return returnAlert("비밀번호 오류", "저장된 비밀번호와 다릅니다!")
                                    
                                case .userInformationDifferentError:
                                    return returnAlert("회원정보 오류", "저장된 회원정보와 다릅니다!")
                                    
                                case .networkError:
                                    return returnAlert("네트워크 오류", "서버와 연결할 수 없습니다 ")
                                    
                                case .tooManyLoginRequests:
                                    return returnAlert("로그인 요청 과다", "너무 많은 로그인 요청을 단시간에 전송하여 일정 시간 접근이 제한되었습니다.")
                                    
                                case .tooManyAPIRequests:
                                    return returnAlert("⚠️ 서버 요청 횟수 과다", "서버 요청 횟수가 초과 되었습니다. 잠시 후 다시 사용 가능합니다.")
                                }
                            }
                            
                            Button(action: {
                                showWebView = true
                            }) {
                                Text("도움이 필요하신가요?")
                            }
                            .buttonStyle(.plain)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .foregroundStyle(Color.blue)
                        }
                        .padding(30)
                    }
                    .scrollIndicators(.hidden)
                    
                    .sheet(isPresented: $showWebView) {
                        WebView(urlString: faqURL)
                    }
                    
                    .navigationTitle("👋 환영합니다!")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    // MARK: - Alert 함수
    private func returnAlert(_ title: String, _ message: String) -> Alert{
        return Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text("확인"))
        )
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
        let validPrefixes = ["201", "2020", "2021", "2022", "2023", "2024"]
        let prefixBool: Bool = validPrefixes.contains { inputStudentID.hasPrefix($0) }
        let onlyNumberBool: Bool = inputStudentID.allSatisfy(\.isNumber)
        
        if emptyBool && lengthBool && prefixBool && onlyNumberBool {
            studentIDFormatErrorString = "학번이 적절한 형식입니다"
            studentIDFormatErrorColor = .green
        } else {
            studentIDFormatErrorString = "학번 형식이 올바르지 않습니다"
            studentIDFormatErrorColor = .red
            return false
        }
        
        return true
    }
    
    // Password format
    private func isPasswordFormatError() -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[~!@]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return !passwordTest.evaluate(with: inputPassword)
    }
    
    // MARK: - 비밀번호 입력 시 형식과 다르면 변경
    private func passwordFormatIsWrong() {
        if isPasswordFormatError() {
            passwordCheckString = "비밀번호 형식이 틀립니다"
            passwordCheckColor = .red
        } else {
            passwordCheckString = "적절한 비밀번호 형식입니다"
            passwordCheckColor = .green
        }
    }
    
    // Password different
    private func isPasswordDifferentError() -> Bool {
        return inputPassword == inputPasswordAgain
    }
    
    // MARK: - 재확인 비밀번호 입력 시 비밀번호와 다르다면 변경
    private func passwordCheckIsDifferent() {
        if !isPasswordDifferentError() {
            passwordDifferentString = "비밀번호가 다릅니다"
            passwordDifferentColor = .red
        } else {
            passwordDifferentString = "비밀번호가 일치합니다"
            passwordDifferentColor = .green
        }
    }
    
    private func studentNameFormatValidation() -> Bool {
        let emptyBool: Bool = !inputStudentName.isEmpty
        let atLeast2Bool: Bool = inputStudentName.count >= 2
        let placeholderBool: Bool = inputStudentName != "이름"
        let containsNumber: Bool = inputStudentName.rangeOfCharacter(from: .decimalDigits) != nil
        let catchCharacterSet = CharacterSet(charactersIn: "!@#$%^&*()-_=+[{]}\\|;:'\",<.>/?`~")
        let containsSpecialCharacter: Bool = inputStudentName.rangeOfCharacter(from: catchCharacterSet) != nil
        let limitLength: Bool = inputStudentName.count <= 10
        if emptyBool && placeholderBool && !containsNumber && !containsSpecialCharacter && atLeast2Bool && limitLength {
            studentNameFormatErrorString = "이름이 적절한 형식입니다"
            studentNameFormatErrorColor = .green
            return true
        } else {
            studentNameFormatErrorString = "이름 형식이 올바르지 않습니다"
            studentNameFormatErrorColor = .red
            return false
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
        
        if isPasswordFormatError() {
            showAlert = .passwordFormatError
            return
        }
        
        if !isPasswordDifferentError() {
            showAlert = .passwordDifferentError
            return
        }
        
        savePassword(studentID: inputStudentID, password: inputPassword)
        
        showAlert = .recheck
    }
    
    func savePassword(studentID: String, password: String) {
        print("Save password")
        
        let serviceName = "KyeonghoJang.AttendanceCheck"
        
        let data = password.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: studentID,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Password saved successfully")
        } else {
            print("Error saving password: \(status)")
        }
    }
    
    func getPassword(service: String, account: String) -> String? {
        print("Get password")
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess {
            guard let data = item as? Data else { return nil }
            return String(decoding: data, as: UTF8.self)
        } else {
            print("Error retrieving password: \(status)")
            return nil
        }
    }
    
    private func returnWarningTitleAndMessage(statusCode: Int) -> (title: String, message: String) {
        var warningTitle = ""
        var warningMessage = ""
        
        switch accountAlertStatusCode {
        case 401:
            warningTitle = "⚠️ 토큰 오류"
            warningMessage = "유효하지 않은 토큰을 사용하고 있습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
        case 409:
            warningTitle = "⚠️ 계정 오류"
            warningMessage = "서버에서 사용자 정보가 삭제되었습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
        case 412:
            warningTitle = "⚠️ 중복 로그인"
            warningMessage = "새로운 기기에서 로그인되었습니다.\n이전 기기에서 로그인된 정보는 삭제됩니다."
        case 429:
            warningTitle = "⚠️ 로그인 횟수 초과"
            warningMessage = "로그인 횟수가 초과 되었습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
        default:
            print("Warning")
        }
        
        return (warningTitle, warningMessage)
    }
}

#Preview {
    LoginView()
}
