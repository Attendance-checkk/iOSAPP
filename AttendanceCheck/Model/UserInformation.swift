//
//  UserInformation.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

class UserInformation: ObservableObject {
    @AppStorage("storedLoginState") var storedLoginState: Bool?
    @Published var loginState: Bool = false
    
    @AppStorage("department") var department: String?
    @AppStorage("studentID") var studentID: String?
    @AppStorage("studentName") var studentName: String?
    @AppStorage("JWT") var javaWebToken: String?
    
    init() {
        self.loginState = storedLoginState ?? false
    }
    
    public func login(completion: @escaping (Bool) -> Void) {
        guard let studentID = studentID, !studentID.isEmpty,
              let studentName = studentName, !studentName.isEmpty,
              let department = department, !department.isEmpty
        else {
            completion(false)
            return
        }
        
        let parameters = "{\r\n    \"student_code\" : \"\(studentID)\",\r\n    \"name\" : \"\(studentName)\",\r\n    \"major\" : \"\(department)\"\r\n}"
        let postData = parameters.data(using: .utf8)
        
        guard let requestURL = URL(string: "http://54.180.7.191:9999/user/login") else {
            print("Error: Invalid URL")
            completion(false)
            return
        }
        var request = URLRequest(url: requestURL,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let code = responseJSON["code"] as? Int, code == 200,
                    let tokenInfo = responseJSON["token"] as? [String: Any],
                    let accessToken = tokenInfo["access_token"] as? String {
                    DispatchQueue.main.async {
                        self.javaWebToken = accessToken
                        completion(true)
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } catch {
                print("Login JSON parsing error: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }

        task.resume()
    }
    
    public func userDelete() {
        guard let javaWebToken, !javaWebToken.isEmpty else { return }
        guard let requestURL = URL(string: "http://54.180.7.191:9999/user") else { return }
        
        var request = URLRequest(url: requestURL,timeoutInterval: Double.infinity)
                request.addValue(javaWebToken, forHTTPHeaderField: "Authorization")

        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }
    
    public func clearUserInformation() {
        department = nil
        studentID = nil
        studentName = nil
        javaWebToken = nil
        
        loginState = false
        storedLoginState = false
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
