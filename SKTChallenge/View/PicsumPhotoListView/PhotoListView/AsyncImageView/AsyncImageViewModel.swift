//
//  AsyncImageViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

class AsyncImageViewModel: ObservableObject {

    @Published var image: Image?
    @Published var isLoading = false
    @Published var showRetryButton = false

    private var imageLoader: ImageLoaderProtocol

    init(imageLoader: ImageLoaderProtocol = ImageLoader.shared) {
        self.imageLoader = imageLoader
    }

    func load(fromURL url: URL) async {

        await MainActor.run {
            isLoading = true
            showRetryButton = false
        }

        if let (_, image) = await imageLoader.loadImage(from: url) {
            await MainActor.run {
                self.image = Image(uiImage: image)
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.isLoading = false
                self.showRetryButton = true
            }
        }
    }
}
