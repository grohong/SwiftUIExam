//
//  AsyncImageView.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

struct AsyncImageView: View {

    @StateObject var viewModel: AsyncImageViewModel

    init(viewModel: AsyncImageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .success(let image):
            image.resizable()
                .aspectRatio(contentMode: .fit)
        case .failed:
            ZStack {
                Rectangle()
                    .fill(.gray)

                Button(action: {
                    Task { await viewModel.loadImage() }
                }) {
                    Label("다시 시도", systemImage: "arrow.clockwise")
                }
                .font(.caption)
                .padding()
                .foregroundColor(.primary)
            }
        }
    }
}
