//
//  ImageLoaderTests.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/26/24.
//

import XCTest
@testable import SKTChallenge

class ImageLoaderTests: XCTestCase {

    func testLoadImageWithMockCache() async {
        let mockCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

        let imageURL = URL(string: "https://picsum.photos/id/1/5000/3333")!
        let mockImageData = UIImage(systemName: "arrow.clockwise")!.pngData()!
        let mockCachedResponse = CachedURLResponse(response: URLResponse(url: imageURL, mimeType: nil, expectedContentLength: mockImageData.count, textEncodingName: nil), data: mockImageData)
        mockCache.storeCachedResponse(mockCachedResponse, for: URLRequest(url: imageURL))

        let imageLoader = ImageLoader(urlCache: mockCache)
        guard let (loadedURL, loadedImage) = await imageLoader.loadImage(from: imageURL) else {
            XCTFail("캐쉬 실패")
            return
        }

        XCTAssertEqual(loadedURL, imageURL)
        XCTAssertNotNil(loadedImage)
    }
}

