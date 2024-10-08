//
//  DepartmentSelectionView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/8/24.
//

import SwiftUI

struct DepartmentSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedDepartment: String
    @State private var searchText: String = ""
    
    let departments = [
        "사물인터넷학과",
        "의료IT공학과",
        "정보보호학과",
        "컴퓨터소프트웨어공학과",
        "AI∙빅데이터학과",
        "메타버스&게임학과"
    ]
    
    private var filteredDepartments: [String] {
        if searchText.isEmpty {
            departments
        } else {
            departments.filter { $0.contains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("학과 선택")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            TextField("학과를 검색해주세요", text: $searchText)
                .padding(15)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            
            List(filteredDepartments, id: \.self) { department in
                Button(action: {
                    selectedDepartment = department
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(department)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .listStyle(PlainListStyle())
            .cornerRadius(10)
            .overlay (
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primary, lineWidth: 2)
                    .opacity(0.5)
                )
        }
        .padding(20)
    }
}

#Preview {
    DepartmentSelectionView(selectedDepartment: .constant("사물인터넷학과"))
}
