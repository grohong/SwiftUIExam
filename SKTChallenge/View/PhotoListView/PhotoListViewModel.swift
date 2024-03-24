//
//  PhotoListViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

class PhotoListViewModel: ObservableObject {

    @Published var imageList = [PicsumImage]()
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let networkService: PicsumNetworkServiceProtocol

    init(networkService: PicsumNetworkServiceProtocol = PicsumNetworkService.shared) {
        self.networkService = networkService
    }

    func fetchImageList() async {
        guard imageList.isEmpty == true else { return }
        await MainActor.run { self.isLoading = true }
        do {
            let fetchedImageList = try await networkService.fetchImageList(page: 1, limit: 10)
            await MainActor.run {
                self.imageList = fetchedImageList
            }
        } catch {
            await MainActor.run {
                self.errorMessage = """
                이미지 리스트 API에서 오류가 발생했습니다.
                다시 시도해주세요.
                """
            }
        }
        await MainActor.run {
            self.isLoading = false
        }
    }
}
