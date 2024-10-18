//
//  CautionView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/18/24.
//

import SwiftUI

struct CautionView: View {
    var body: some View {
        VStack {
            HStack {
                Text("계정을 한 번 삭제하면 복구할 수 없습니다.\n계정 삭제 옵션은 개인정보(학과, 학번, 이름)를 잘못 입력하신 경우에만 사용해주시기 바랍니다.")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding()
            
            Spacer()
            
            .navigationTitle("계정 삭제 주의사항")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CautionView()
}
