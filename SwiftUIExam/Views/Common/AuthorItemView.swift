//
//  AuthorItemView.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/26/24.
//

import SwiftUI

struct AuthorItemView: View {

    let author: String
    var onTapAction: () -> Void

    var body: some View {
        HStack {
            Text(author)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onTapAction() }
    }
}
