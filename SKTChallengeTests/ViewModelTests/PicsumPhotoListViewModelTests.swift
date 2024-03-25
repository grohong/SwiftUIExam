//
//  PhotoListViewModelTests.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest
@testable import SKTChallenge

class PicsumPhotoListViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        do {
            let mockData = try loadTestData()
            let mockImageList = try JSONDecoder().decode([PicsumImage].self, from: mockData)
            mockNetworkService = MockNetworkService(fetchedImageList: mockImageList)
            viewModel = PicsumPhotoListViewModel(networkService: mockNetworkService)
        } catch {
            throw XCTSkip("목 데이터를 찾지 못했습니다: \(error.localizedDescription)")
        }
    }

    var mockNetworkService: MockNetworkService!
    var viewModel: PicsumPhotoListViewModel!

    func testFetchImageListSuccess() async {
        await viewModel.fetchImageList()
        XCTAssertFalse(viewModel.imageList.isEmpty)
        XCTAssertTrue(viewModel.errorMessage == nil)
    }

    func testFetchImageListFailure() async {
        mockNetworkService.shouldReturnError = true
        await viewModel.fetchImageList()
        XCTAssertTrue(viewModel.imageList.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}

class MockNetworkService: PicsumNetworkServiceProtocol {

    var shouldReturnError = false
    let fetchedImageList: [PicsumImage]

    enum MockError: Error {
        case testError
    }

    init(
        shouldReturnError: Bool = false,
        fetchedImageList: [PicsumImage]
    ) {
        self.shouldReturnError = shouldReturnError
        self.fetchedImageList = fetchedImageList
    }

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage] {
        guard shouldReturnError == false else { throw MockError.testError }
        return fetchedImageList
    }
}
