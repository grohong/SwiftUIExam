//
//  PhotoListViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

class PhotoListViewModel: ObservableObject {

    @Published var imageList = [PicsumImage]()

    private let networkService: PicsumNetworkServiceProtocol

    init(networkService: PicsumNetworkServiceProtocol = PicsumNetworkService.shared) {
        self.networkService = networkService
    }

    func fetchImageList() async {
        do {
            let fetchedImageList = try await networkService.fetchImageList(page: 1, limit: 10)
            await MainActor.run {
                self.imageList = fetchedImageList
            }
        } catch {
            print("Error fetching images:", error)
        }
    }
}
