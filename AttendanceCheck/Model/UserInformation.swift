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
    @AppStorage("accessToken") var accessToken: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoiYWNjZXNzX3Rva2VuIiwidXNlcl9pZCI6NjAsImlhdCI6MTcyOTU1OTg2MSwiZXhwIjoxNzMwODU1ODYxLCJpc3MiOiJob25nc2kifQ.caE6RxEKDhYTbpNdVRtSaRBWaUtIQMFy7JuaHODAUQk"
    @AppStorage("refreshToken") var refreshToken: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaF90b2tlbiIsInVzZXJfaWQiOjYwLCJpYXQiOjE3Mjk1NTk4NjEsImV4cCI6MTczMDg1NTg2MSwiaXNzIjoiaG9uZ3NpIn0.8sWXtyUKcP2XPvWL290C45GkDA-TqsDi-ElGagj7pRQ"
    
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
                    let accessToken = tokenInfo["access_token"] as? String,
                    let refreshToken = tokenInfo["refresh_token"] as? String {
                    DispatchQueue.main.async {
                        self.accessToken = accessToken
                        self.refreshToken = refreshToken
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
    
    public func accessTokenRefresh() {
        let refreshToken = refreshToken
        guard let requrestURL = URL(string: "http://54.180.7.191:9999/jwt/refresh") else { return }
        
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
        guard let requestURL = URL(string: "http://54.180.7.191:9999/user") else { return }
        
        var request = URLRequest(url: requestURL,timeoutInterval: Double.infinity)
                request.addValue(accessToken, forHTTPHeaderField: "Authorization")

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
        accessToken = ""
        
        loginState = false
        storedLoginState = false
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
