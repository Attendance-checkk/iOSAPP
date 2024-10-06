//
//  MenuView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI

struct MenuView: View {
    let departmentString: String
    let studentNumber: String
    let studentName: String
    let faqURL: URL = URL(string: "https://potent-barnacle-025.notion.site/FAQ-116c07204d29805a8418d9a37bf330a2?pvs=4")!
    let surveyURL: URL = URL(string: "https://www.google.com/")!
    
    @State private var isNotification: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("학생 정보")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    HStack {
                        Text("학과")
                        Spacer()
                        Text(departmentString)
                    }
                    
                    HStack {
                        Text("학번")
                        Spacer()
                        Text(studentNumber)
                    }
                    
                    HStack {
                        Text("이름")
                        Spacer()
                        Text(studentName)
                    }
                }
                
                Section(header: Text("설정")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                ) {
                    Toggle(isOn: $isNotification) {
                        Text("🔔 알림 설정")
                    }
                    
                    Link(destination: faqURL) {
                        HStack {
                            Text("🌐 문의하기")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Link(destination: surveyURL) {
                        HStack {
                            Text("🌐 문의하기")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("메뉴")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MenuView(departmentString: "사물인터넷학과", studentNumber: "20181520", studentName: "장경호")
}
