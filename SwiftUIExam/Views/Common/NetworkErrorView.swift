//
//  NetworkErrorView.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct NetworkErrorView: View {
    
    var errorMessage: String
    var retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text(errorMessage)
                .foregroundColor(.secondary)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Label("다시 시도", systemImage: "arrow.clockwise")
            }
        }
    }
}

#Preview {
    NetworkErrorView(
        errorMessage: """
        네트워트 오류가 발생했습니다.
        다시 시도해주세요.
        """,
        retryAction: { }
    )
}
