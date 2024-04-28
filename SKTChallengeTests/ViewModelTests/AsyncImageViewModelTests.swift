//
//  AsyncImageViewModelTests.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/26/24.
//

import XCTest
@testable import SKTChallenge

class AsyncImageViewModelTests: XCTestCase {

    func testLoadCacheImageSuccess() async {
        let mockImageLoader = MockImageLoader()
        mockImageLoader.mockImage = UIImage(systemName: "photo")!
        let viewModel = await AsyncImageViewModel(imageLoader: mockImageLoader, url: URL(string: "https://picsum.photos/id/1/5000/3333")!, loadKind: .resizeWidth(width: .infinity))

        await viewModel.loadImage()

        switch await viewModel.state {
        case .success:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
    
    func testLoadCacheImageFailure() async {
        let mockImageLoader = MockImageLoader()
        mockImageLoader.mockImage = nil
        let viewModel = await AsyncImageViewModel(imageLoader: mockImageLoader, url: URL(string: "https://picsum.photos/id/1/5000/3333")!, loadKind: .resizeWidth(width: .infinity))

        await viewModel.loadImage()

        switch await viewModel.state {
        case .failed:
            XCTAssertTrue(true)
        default:
            XCTFail()
        }
    }
}

class MockImageLoader: ImageLoaderProtocol {

    var mockImage: UIImage?
    var mockError: Error?

    func loadImage(from url: URL, loadKind: SKTChallenge.ImageLoader.LoadKind) async -> (URL, UIImage)? {
        if let mockImage = mockImage {
            return (url, mockImage)
        } else {
            return nil
        }
    }
}
