//
//  AsyncImageView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

struct AsyncImageView: View {

    @StateObject var viewModel: AsyncImageViewModel

    private let url: URL

    init(
        viewModel: AsyncImageViewModel = AsyncImageViewModel(),
        url: URL
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.url = url
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let image = viewModel.image {
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } else if viewModel.showRetryButton {
                Button(action: {
                    Task { await viewModel.load(fromURL: url) }
                }) {
                    Label("다시 시도", systemImage: "arrow.clockwise")
                }
                .font(.caption)
                .padding()
                .foregroundColor(.primary)
            } else {
                ProgressView()
                    .onAppear {
                        Task { await viewModel.load(fromURL: url) }
                    }
            }
        }
    }
}
