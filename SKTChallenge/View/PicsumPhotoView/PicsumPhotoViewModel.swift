//
//  PicsumPhotoViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/26/24.
//

import Foundation

class PicsumPhotoViewModel: ObservableObject {

    enum State {
        case loading
        case success(PicsumImage)
        case failed(String)
    }

    @Published var state: State = .loading

    private let networkService: PicsumNetworkServiceProtocol
    private let id: String

    init(
        networkService: PicsumNetworkServiceProtocol = PicsumNetworkService.shared,
        id: String
    ) {
        self.networkService = networkService
        self.id = id
        Task { await fetchImage() }
    }

    func fetchImage() async {
        await MainActor.run {
            state = .loading
        }

        do {
            let fetchedImage = try await networkService.fetchImageDetail(id: id)
            await MainActor.run { state = .success(fetchedImage) }
        } catch {
            await MainActor.run {
                state = .failed(
                    """
                    이미지 API에서 오류가 발생했습니다.
                    다시 시도해주세요.
                    """
                )
            }
        }
    }
}
