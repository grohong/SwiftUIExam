//
//  PhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

struct PhotoListView: View {

    @Binding private var imageList: [PicsumImage]
    @Binding private var isFetchMoreLoading: Bool

    private let fetchMoreAction: () -> Void
    private let refreshAction: () async -> Void

    struct Constants {
        static let gridSpacing: CGFloat = 20
        static let gridColumnCount: Int = 1
        static let gridCellRatio: CGFloat = 3333 / 5000
        static let standardWidth: CGFloat = 500
    }

    init(
        imageList: Binding<[PicsumImage]>,
        isFetchMoreLoading: Binding<Bool>,
        fetchMoreAction: @escaping () -> Void,
        refreshAction: @escaping () async -> Void
    ) {
        self._imageList = imageList
        self._isFetchMoreLoading = isFetchMoreLoading
        self.fetchMoreAction = fetchMoreAction
        self.refreshAction = refreshAction
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            GeometryReader { geometry in
                let columnCount = geometry.size.width > Constants.standardWidth ? Constants.gridColumnCount + 1 : Constants.gridColumnCount
                let itemWidth = (geometry.size.width - (Constants.gridSpacing * CGFloat(columnCount + 1))) / CGFloat(columnCount)

                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(itemWidth)), count: columnCount),
                        spacing: Constants.gridSpacing
                    ) {
                        ForEach(imageList) { image in
                            AsyncImageView(
                                url: image.downloadURL
                            )
                            .frame(width: itemWidth, height: itemWidth * Constants.gridCellRatio)
                            .onAppear {
                                if image == imageList.last {
                                    fetchMoreAction()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if isFetchMoreLoading == true {
                        ProgressView()
                    }
                }
                .refreshable { await refreshAction() }
            }
        } else {
            GridCollectionView(
                imageList: imageList,
                fetchMoreAction: fetchMoreAction,
                refreshAction: refreshAction
            )
        }
    }
}
