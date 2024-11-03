//
//  UserInformation.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

class UserInformation: ObservableObject {
    static let instance = UserInformation()
    
    @AppStorage("storedLoginState") var storedLoginState: Bool?
    @Published var loginState: Bool = false
    
    @AppStorage("department") var department: String?
    @AppStorage("studentID") var studentID: String?
    @AppStorage("studentName") var studentName: String?
    @AppStorage("accessToken") var accessToken: String?
    @AppStorage("refreshToken") var refreshToken: String?
    
    init() {
        self.loginState = storedLoginState ?? false
    }
    
    public func login(completion: @escaping (Bool, Int?, String) -> Void) {
        guard let studentID = studentID, !studentID.isEmpty,
              let studentName = studentName, !studentName.isEmpty,
              let department = department, !department.isEmpty
        else {
            print("Error: Missing studentID, studentName, or department.")
            completion(false, 800, "Missing studentID, studentName, or department.")
            return
        }
        
        guard let password = getPassword(service: "KyeonghoJang.AttendanceCheck", account: studentID) else {
            return completion(false, 80, "Invalid password")
        }
        
        let parameters = "{\r\n    \"student_code\" : \"\(studentID)\",\r\n    \"name\" : \"\(studentName)\",\r\n    \"major\" : \"\(department)\",\r\n    \"password\" : \"\(password)\"\r\n}"
        let postData = parameters.data(using: .utf8)
        
        guard let requestURL = URL(string: "https://\(getSecurityCode("API_URL")):\(getSecurityCode("PORT"))\(getSecurityCode("LOGIN_URL"))") else {
            print("Error: Invalid URL")
            completion(false, 801, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: requestURL, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error during login request: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, 802, error.localizedDescription)
                }
                return
            }
            
            guard let data = data else {
                print("Error: No data received.")
                DispatchQueue.main.async {
                    completion(false, 803, "No data received.")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let tokenInfo = responseJSON["token"] as? [String: Any],
                               let accessToken = tokenInfo["access_token"] as? String,
                               let refreshToken = tokenInfo["refresh_token"] as? String {
                                DispatchQueue.main.async {
                                    self.accessToken = accessToken
                                    self.refreshToken = refreshToken
                                    completion(true, 200, "Login successful.")
                                }
                                return
                            } else {
                                print("Error: Missing token information in response.")
                            }
                        }
                    } catch {
                        print("Login JSON parsing error: \(error)")
                    }
                    
                case 408:
                    print("Error: Request Timeout. Already registered user.")
                    DispatchQueue.main.async {
                        completion(false, 408, "Already registered user.")
                    }
                    return
                    
                case 409:
                    print("Error: Conflict. User might already exist.")
                    DispatchQueue.main.async {
                        completion(false, 409, "Conflict. User might already exist.")
                    }
                    return
                
                case 412:
                    print("Error: Precondition Failed. Please check your input.")
                    DispatchQueue.main.async {
                        completion(false, 412, "Precondition Failed. Please check your input.")
                    }
                    return
                
                case 500:
                    print("Error: Network Error.")
                    DispatchQueue.main.async {
                        completion(false, 500, "Network Error.")
                    }
                    return
                
                case 405:
                    print("Error: Password does not match.")
                    DispatchQueue.main.async {
                        completion(false, 405, "Password does not match.")
                    }
                    return
                
                case 406:
                    print("Error: Does not match stored user information.")
                    DispatchQueue.main.async {
                        completion(false, 406, "Does not match stored user information.")
                    }
                    return
                    
                case 429:
                    print("Error: Too many user login requests sended in 1 minute")
                    DispatchQueue.main.async {
                        completion(false, 429, "Too many user login requests sended in 1 minute.")
                    }
                    
                case 430:
                    print("Error: Too many API request in 1 minute")
                    DispatchQueue.main.async {
                        completion(false, 430, "Too many API request in 1 minute.")
                    }
                
                default:
                    print("Login failed with code: \(httpResponse.statusCode)")
                }
            } else {
                print("Error: Invalid response format.")
            }
            
            DispatchQueue.main.async {
                completion(false, 804, "Login failed.")
            }
        }

        task.resume()
    }
    
    public func accessTokenRefresh() {
        guard let refreshToken = refreshToken else { return }
        guard let requrestURL = URL(string: "https://\(getSecurityCode("API_URL")):\(getSecurityCode("PORT"))\(getSecurityCode("REFRESH"))") else { return }
        
        var request = URLRequest(url: requrestURL, timeoutInterval: Double.infinity)
        request.addValue(refreshToken, forHTTPHeaderField: "Authorization")

        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        if let reponseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let code = reponseJSON["code"] as? Int, code == 200,
                           let tokenInfo = reponseJSON["token"] as? [String: Any],
                           let accessToken = tokenInfo["accessToken"] as? String,
                           let refreshToken = tokenInfo["refreshToken"] as? String {
                            DispatchQueue.main.async {
                                self.accessToken = accessToken
                                self.refreshToken = refreshToken
                            }
                            return
                        }
                    } catch {
                        print("Access Token refresh error: \(error)")
                    }
                
                case 409:
                    print("eventPostError: \(httpResponse.statusCode), 새로운 기기로 로그인.")
                    return
                    
                case 412:
                    print("eventPostError: \(httpResponse.statusCode), 새로운 기기로 로그인.")
                    return
                    
                default:
                    print("eventPostError: 응답 코드 \(httpResponse.statusCode), 알 수 없는 오류 발생")
                    return
                }
                
            }
        }

        task.resume()

    }
    
    public func userDelete(completion: @escaping (Bool, Int?) -> Void) {
        guard let accessToken, !accessToken.isEmpty else {
            print("No access token")
            completion(false, nil)
            return
        }
        
        guard let requestURL = URL(string: "https://\(getSecurityCode("API_URL")):\(getSecurityCode("PORT"))\(getSecurityCode("DELETE_URL"))") else {
            completion(false, nil)
            return
        }
        
        print(requestURL)
        
        var request = URLRequest(url: requestURL, timeoutInterval: Double.infinity)
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("응답이 HTTP가 아닙니다.")
                completion(false, nil)
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                self.clearUserInformation()
                print("계정 삭제 성공: \(String(data: data ?? Data(), encoding: .utf8)!)")
                completion(true, httpResponse.statusCode)
            case 400...499:
                print("클라이언트 오류 발생: \(httpResponse.statusCode)")
                completion(false, httpResponse.statusCode)
            case 500...599:
                print("서버 오류 발생: \(httpResponse.statusCode)")
                completion(false, httpResponse.statusCode)
            default:
                print("예상하지 못한 오류 발생: \(httpResponse.statusCode)")
                completion(false, httpResponse.statusCode)
            }
        }

        task.resume()
    }
    
    func fetchUserSettingInfo(completion: @escaping (Bool, Int, String, String, String) -> Void) {
        guard let token = UserInformation.instance.accessToken else {
            completion(false, 0, "", "", "")
            return
        }
        
        var request = URLRequest(url: URL(string: "https://\(getSecurityCode("API_URL")):\(getSecurityCode("PORT"))\(getSecurityCode("USER_URL"))")!, timeoutInterval: Double.infinity)
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 오류가 발생한 경우 처리
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false, 0, "", "", "")
                return
            }
            
            // 응답 처리
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response format.")
                completion(false, 0, "", "", "")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                // 성공적인 응답 처리
                if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let major = jsonResponse["major"] as? String,
                           let code = jsonResponse["code"] as? String,
                           let name = jsonResponse["name"] as? String {
                            completion(true, httpResponse.statusCode, major, code, name)
                        } else {
                            print("Error: Missing expected keys in JSON response.")
                            completion(false, httpResponse.statusCode, "", "", "")
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                        completion(false, httpResponse.statusCode, "", "", "")
                    }
                }
            case 409:
                print("Conflict: The request could not be completed due to a conflict with the current state of the target resource.")
                completion(false, 409, "", "", "")
            case 412:
                print("Precondition Failed: The server does not meet one of the preconditions that the requester put on the request.")
                completion(false, 412, "", "", "")
            case 429:
                print("Error: Too many user login requests sended in 1 minute")
                DispatchQueue.main.async {
                    completion(false, 429, "", "", "")
                }
            case 430:
                print("Error: Too many API request in 1 minute")
                DispatchQueue.main.async {
                    completion(false, 430, "", "", "")
                }
            default:
                print("Error: Received HTTP status code \(httpResponse.statusCode)")
                completion(false, httpResponse.statusCode, "", "", "")
            }
        }

        task.resume()
    }
    
    public func clearUserInformation() {
        print("clearUserInformation")
        
        DispatchQueue.main.async {
            self.storedLoginState = false
            self.department = nil
            self.studentID = nil
            self.studentName = nil
            self.accessToken = nil
            self.refreshToken = nil
            
            self.loginState = false
            self.storedLoginState = false
            
            print("department: \(String(describing: self.department))")
            print("studentID: \(String(describing: self.studentID))")
            print("studentName: \(String(describing: self.studentName))")
            print("accessToken: \(String(describing: self.accessToken))")
            print("refreshToken: \(String(describing: self.refreshToken))")
            print("loginState: \(self.loginState)")
            print("storeLoginState: \(String(describing: self.storedLoginState))")
            
            
            
            self.objectWillChange.send()
        }
    }
    
    private func getSecurityCode(_ request: String) -> String {
        if let code = Bundle.main.object(forInfoDictionaryKey: request) as? String {
            return code
        } else {
            return ""
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
            print("Successfully retrieved password")
            guard let data = item as? Data else { return nil }
            return String(decoding: data, as: UTF8.self)
        } else {
            print("Error retrieving password: \(status)")
            return nil
        }
    }
}
