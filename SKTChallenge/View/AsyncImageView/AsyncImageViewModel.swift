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

    func load(fromURL url: URL) async {

        await MainActor.run {
            isLoading = true
            showRetryButton = false
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = Image(uiImage: uiImage)
                }
            } else {
                await MainActor.run {
                    self.showRetryButton = true
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.showRetryButton = true
            }
        }

        await MainActor.run {
            self.isLoading = false
        }
    }
}
