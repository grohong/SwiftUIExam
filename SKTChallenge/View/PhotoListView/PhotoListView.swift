//
//  PhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct PhotoListView: View {

    @StateObject var viewModel: PhotoListViewModel

    struct Constants {
        static let gridSpacing: CGFloat = 20
        static let gridColumnCount: Int = 1
        static let gridCellRatio: CGFloat = 3333 / 5000

        static let standardWidth: CGFloat = 500
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
                    GeometryReader { geometry in
                        let columnCount = geometry.size.width > Constants.standardWidth ? Constants.gridColumnCount + 1 : Constants.gridColumnCount
                        let itemWidth = (geometry.size.width - (Constants.gridSpacing * CGFloat(columnCount + 1))) / CGFloat(columnCount)

                        ScrollView {
                            LazyVGrid(
                                columns: Array(repeating: GridItem(.fixed(itemWidth)), count: columnCount),
                                spacing: Constants.gridSpacing
                            ) {
                                ForEach(viewModel.imageList) { image in
                                    AsyncImageView(
                                        url: image.downloadURL
                                    )
                                    .frame(width: itemWidth, height: itemWidth * Constants.gridCellRatio)
                                    .cornerRadius(8)
                                    .onAppear {
                                        if image == viewModel.imageList.last {
                                            Task { await viewModel.fetchMoreImageList() }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)

                            if viewModel.isFetchMoreLoading == true {
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .navigationTitle(Constants.navigationTitle)
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

