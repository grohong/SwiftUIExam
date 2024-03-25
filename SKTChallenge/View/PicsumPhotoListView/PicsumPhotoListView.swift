//
//  PicsumPhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct PicsumPhotoListView: View {

    @StateObject var viewModel: PicsumPhotoListViewModel

    struct Constants {
        static let navigationTitle: String = "Lorem Picsum"
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isFetchLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    NetworkErrorView(errorMessage: errorMessage) {
                        Task { await viewModel.fetchImageList() }
                    }
                } else {
                    PhotoListView(
                        imageList: $viewModel.imageList,
                        isFetchMoreLoading: $viewModel.isFetchMoreLoading,
                        fetchMoreAction: {
                            Task { await viewModel.fetchMoreImageList() }
                        },
                        refreshAction: { await viewModel.refreshImageList() }
                    )
                }
            }
            .navigationTitle(Constants.navigationTitle)
        }
        .onAppear {
            Task { await viewModel.fetchImageList() }
        }
    }
}

#Preview {
    PicsumPhotoListView(viewModel: PicsumPhotoListViewModel())
}

