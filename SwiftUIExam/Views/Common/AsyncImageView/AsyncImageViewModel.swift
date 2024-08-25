//
//  AsyncImageViewModel.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

@MainActor
final class AsyncImageViewModel: ObservableObject {

    enum State {
        case loading
        case success(Image)
        case failed
    }

    @Published var state: State = .loading

    private let imageLoader: ImageLoaderProtocol
    private let url: URL
    private let loadKind: ImageLoader.LoadKind

    init(
        imageLoader: ImageLoaderProtocol = ImageLoader.shared,
        url: URL,
        loadKind: ImageLoader.LoadKind
    ) {
        self.imageLoader = imageLoader
        self.url = url
        self.loadKind = loadKind
        Task { await loadImage() }
    }

    func loadImage() async {
        state = .loading

        if let (_, uiImage) = await imageLoader.loadImage(from: url, loadKind: loadKind) {
            state = .success(Image(uiImage: uiImage))
        } else {
            state = .failed
        }
    }
}
