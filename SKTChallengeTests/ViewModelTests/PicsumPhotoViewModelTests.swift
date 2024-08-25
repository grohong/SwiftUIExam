//
//  PicsumPhotoViewModelTests.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/26/24.
//

import XCTest
@testable import SKTChallenge

class PicsumPhotoViewModelTests: XCTestCase {

    @MainActor 
    override func setUpWithError() throws {
        do {
            let mockData = try loadMockData(file: .image)
            let mockImage = try JSONDecoder().decode(PicsumImage.self, from: mockData)
            self.mockNetworkService = MockNetworkService()
            self.mockNetworkService.fetchedImage = mockImage
            self.mockImage = mockImage
            self.viewModel = PicsumPhotoViewModel(networkService: mockNetworkService, id: "0")
        } catch {
            throw XCTSkip("목 데이터를 찾지 못했습니다: \(error.localizedDescription)")
        }
    }

    var mockNetworkService: MockNetworkService!
    var mockImage: PicsumImage!

    var viewModel: PicsumPhotoViewModel!

    func testFetchImageSuccess() async {
        await viewModel.fetchImage()
        switch await viewModel.state {
        case .success(let image):
            XCTAssertEqual(image, mockImage)
        default:
            XCTFail()
        }
    }

    func testLoadImageFailure() async {
        mockNetworkService.shouldReturnError = true
        await viewModel.fetchImage()
        switch await viewModel.state {
        case .failed:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
}
