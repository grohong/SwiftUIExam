//
//  PicsumPhotoListViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

class PicsumPhotoListViewModel: ObservableObject {

    @Published var imageList = [PicsumImage]()
    @Published var errorMessage: String?

    @Published var isFetchLoading = false
    @Published var isFetchMoreLoading = false

    private let networkService: PicsumNetworkServiceProtocol
    private var currentPage: Int = 1

    private var startIndex: Int { Int.random(in: 1...10) }

    init(networkService: PicsumNetworkServiceProtocol = PicsumNetworkService.shared) {
        self.networkService = networkService
    }

    func fetchImageList() async {
        guard imageList.isEmpty == true else { return }
        await MainActor.run { isFetchLoading = true }

        do {
            let startIndex = startIndex
            let fetchedImageList = try await networkService.fetchImageList(page: startIndex, limit: 10)
            currentPage = startIndex
            await MainActor.run { imageList = fetchedImageList }
        } catch {
            await MainActor.run {
                errorMessage = """
                이미지 리스트 API에서 오류가 발생했습니다.
                다시 시도해주세요.
                """
            }
        }

        await MainActor.run { isFetchLoading = false }
    }

    func refreshImageList() async {
        do {
            let startIndex = startIndex
            let fetchedImageList = try await networkService.fetchImageList(page: startIndex, limit: 10)
            currentPage = startIndex
            await MainActor.run { imageList = fetchedImageList }
        } catch { }
    }

    func fetchMoreImageList() async {
        guard isFetchMoreLoading == false else { return }
        await MainActor.run { isFetchMoreLoading = true }

        do {
            let fetchedImageList = try await networkService.fetchImageList(page: currentPage + 1, limit: 10)
            currentPage += 1
            await MainActor.run { imageList.append(contentsOf: fetchedImageList) }
        } catch { }

        await MainActor.run { isFetchMoreLoading = false }
    }
}
