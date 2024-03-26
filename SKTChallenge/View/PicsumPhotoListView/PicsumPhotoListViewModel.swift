//
//  PicsumPhotoListViewModel.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation
import Combine

class PicsumPhotoListViewModel: ObservableObject {

    @Published var filteredImageList = [PicsumImage]()

    @Published var errorMessage: String?

    @Published var isFetchLoading = false
    @Published var isFetchMoreLoading = false

    @Published var authorList = [String]()
    @Published var searchText = ""

    @Published private(set) var imageList = [PicsumImage]()

    private let networkService: PicsumNetworkServiceProtocol
    private var currentPage: Int = 1

    private var startIndex: Int { Int.random(in: 1...10) }

    private var cancellables = Set<AnyCancellable>()

    init(networkService: PicsumNetworkServiceProtocol = PicsumNetworkService.shared) {
        self.networkService = networkService

        Publishers.CombineLatest($searchText, $imageList)
            .map { searchText, imageList in
                imageList
                    .filter { searchText.isEmpty || $0.author.lowercased().contains(searchText.lowercased()) }
            }
            .removeDuplicates { previous, current in
                previous == current
            }
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .assign(to: &$filteredImageList)

        $searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .map { searchText in
                self.imageList
                    .filter { searchText.isEmpty || $0.author.lowercased().contains(searchText.lowercased()) }
                    .map(\.author)
            }
            .map { Array(Set($0)).sorted() }
            .assign(to: \.authorList, on: self)
            .store(in: &cancellables)
    }

    func fetchImageList() async {
        guard imageList.isEmpty == true else { return }
        await MainActor.run { isFetchLoading = true }

        do {
            let startIndex = startIndex
            let fetchedImageList = try await networkService.fetchImageList(page: startIndex, limit: 10)
            currentPage = startIndex
            await MainActor.run { imageList = fetchedImageList.uniqueIdArray }
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
            await MainActor.run {
                searchText = ""
                imageList = fetchedImageList.uniqueIdArray
            }
        } catch { }
    }

    func fetchMoreImageList() async {
        guard isFetchMoreLoading == false else { return }
        await MainActor.run { isFetchMoreLoading = true }

        do {
            let fetchedImageList = try await networkService.fetchImageList(page: currentPage + 1, limit: 10)
            currentPage += 1
            let uniqueNewImages = fetchedImageList.filter { Set(imageList.map(\.id)).contains($0.id) == false }
            await MainActor.run { imageList.append(contentsOf: uniqueNewImages) }
        } catch { }

        await MainActor.run { isFetchMoreLoading = false }
    }
}
