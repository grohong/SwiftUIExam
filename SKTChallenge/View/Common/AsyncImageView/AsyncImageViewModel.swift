//
//  AsyncImageViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

class AsyncImageViewModel: ObservableObject {

    enum State {
        case loading
        case success(Image)
        case failed
    }

    @Published var state: State = .loading

    private let imageLoader: ImageLoaderProtocol
    private let url: URL

    init(
        imageLoader: ImageLoaderProtocol = ImageLoader.shared,
        url: URL
    ) {
        self.imageLoader = imageLoader
        self.url = url
        Task { await loadImage() }
    }

    func loadImage() async {

        await MainActor.run { state = .loading }

        if let (_, uiImage) = await imageLoader.loadImage(from: url) {
            await MainActor.run { state = .success(Image(uiImage: uiImage)) }
        } else {
            await MainActor.run { state = .failed }
        }
    }
}
