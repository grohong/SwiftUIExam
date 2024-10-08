//
//  PhotoListViewModelTests.swift
//  SwiftUIExamTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest
@testable import SwiftUIExam

class PicsumPhotoListViewModelTests: XCTestCase {

    @MainActor override func setUpWithError() throws {
        do {
            let mockData = try loadMockData(file: .imageList)
            let mockImageList = try JSONDecoder().decode([PicsumImage].self, from: mockData)
            self.mockNetworkService = MockNetworkService()
            self.mockNetworkService.fetchedImageList = mockImageList
            self.mockImageList = mockImageList
            self.viewModel = PicsumPhotoListViewModel(networkService: mockNetworkService)
        } catch {
            throw XCTSkip("목 데이터를 찾지 못했습니다: \(error.localizedDescription)")
        }
    }

    var mockNetworkService: MockNetworkService!
    var mockImageList = [PicsumImage]()

    var viewModel: PicsumPhotoListViewModel!

    @MainActor
    func testFetchImageListSuccess() async {
        await viewModel.fetchImageList()
        XCTAssertFalse(viewModel.imageList.isEmpty)
        XCTAssertTrue(viewModel.errorMessage == nil)
    }

    @MainActor
    func testFetchImageListFailure() async {
        mockNetworkService.shouldReturnError = true
        await viewModel.fetchImageList()
        XCTAssertTrue(viewModel.imageList.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    @MainActor
    func testUniqueIdImageList() async {
        await viewModel.fetchImageList()
        XCTAssertNotEqual(viewModel.imageList.count, mockImageList.count)
    }

    @MainActor
    func testAuthorList() async throws {
        await viewModel.fetchImageList()
        viewModel.searchText = "a"

        // debounce 시간
        try await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertFalse(viewModel.imageList.isEmpty)
        XCTAssertFalse(viewModel.authorList.isEmpty)
    }

    @MainActor
    func testFilteredImageList() async throws {
        await viewModel.fetchImageList()
        viewModel.searchText = "Alejandro"

        XCTAssertFalse(viewModel.imageList.isEmpty)
        XCTAssertFalse(viewModel.filteredImageList.isEmpty)
        XCTAssertNotEqual(viewModel.imageList.count, viewModel.filteredImageList.count)
    }

    @MainActor
    func testRefreshImageList() async {
        await viewModel.fetchImageList()
        viewModel.searchText = "Alejandro"

        await viewModel.refreshImageList()
        XCTAssertEqual(viewModel.searchText, "")
    }

    @MainActor
    func testFetchMoreImageList() async throws {
        await viewModel.fetchImageList()
        let originImageListCount = viewModel.imageList.count

        let mockData = try loadMockData(file: .fetchMoreImageList)
        let mockImageList = try JSONDecoder().decode([PicsumImage].self, from: mockData)
        mockNetworkService.fetchedImageList = mockImageList

        await viewModel.fetchMoreImageList()
        XCTAssertTrue(originImageListCount < viewModel.imageList.count)
    }
}
