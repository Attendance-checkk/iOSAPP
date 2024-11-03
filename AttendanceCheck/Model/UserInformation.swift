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
        }

        task.resume()

    }
    
    public func userDelete() {
        guard let accessToken, !accessToken.isEmpty else { return }
        guard let requestURL = URL(string: "https://\(getSecurityCode("API_URI"))\(getSecurityCode("DELETE_URL"))") else { return }
        
        var request = URLRequest(url: requestURL,timeoutInterval: Double.infinity)
                request.addValue(accessToken, forHTTPHeaderField: "Authorization")

        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            
            self.clearUserInformation()
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
    
    public func clearUserInformation() {
        DispatchQueue.main.async {
            self.storedLoginState = false
            self.department = nil
            self.studentID = nil
            self.studentName = nil
            self.accessToken = nil
            self.refreshToken = nil
            
            self.loginState = false
            self.storedLoginState = false
            
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
