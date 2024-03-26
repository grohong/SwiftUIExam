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

    @Published var isFetchLoading = true
    @Published var isFetchMoreLoading = false

    @Published var authorList = [String]()
    @Published var searchText = ""

    @Published private(set) var imageList = [PicsumImage]()

    private let networkService: PicsumNetworkServiceProtocol
    private var currentPage: Int = 1
    private var picsumImageIdSet = Set<String>()

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

        Task { await fetchImageList() }
    }

    func fetchImageList() async {
        guard imageList.isEmpty == true else { return }
        await MainActor.run {
            isFetchLoading = true
            errorMessage = nil
        }

        do {
            let startIndex = startIndex
            let fetchedImageList = try await networkService.fetchImageList(page: startIndex, limit: 10).uniqueIdArray
            currentPage = startIndex
            picsumImageIdSet = Set(fetchedImageList.map(\.id))
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
            let fetchedImageList = try await networkService.fetchImageList(page: startIndex, limit: 10).uniqueIdArray
            currentPage = startIndex
            picsumImageIdSet = Set(fetchedImageList.map(\.id))
            await MainActor.run {
                searchText = ""
                imageList = fetchedImageList
            }
        } catch { }
    }

    func fetchMoreImageList() async {
        guard isFetchMoreLoading == false else { return }
        await MainActor.run { isFetchMoreLoading = true }

        do {
            let fetchedImageList = try await networkService.fetchImageList(page: currentPage + 1, limit: 10).uniqueIdArray
            currentPage += 1
            let uniqueNewImages = fetchedImageList.filter { picsumImageIdSet.contains($0.id) == false }
            if uniqueNewImages.isEmpty == false {
                picsumImageIdSet.formUnion(uniqueNewImages.map(\.id)) // 중복되지 않는 새 이미지의 ID를 세트에 추가
                await MainActor.run { imageList.append(contentsOf: uniqueNewImages) }
            }
        } catch { }

        await MainActor.run { isFetchMoreLoading = false }
    }
}
