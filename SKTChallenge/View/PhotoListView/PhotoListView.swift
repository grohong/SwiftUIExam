//
//  PhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct PhotoListView: View {

    @StateObject var viewModel: PhotoListViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let errorMessage = viewModel.errorMessage {
                NetworkErrorView(errorMessage: errorMessage) {
                    Task { await viewModel.fetchImageList() }
                }
            } else {
                List(viewModel.imageList, id: \.id) { image in
                    Text(image.author)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImageList()
            }
        }
    }
}

#Preview {
    PhotoListView(viewModel: PhotoListViewModel())
}

