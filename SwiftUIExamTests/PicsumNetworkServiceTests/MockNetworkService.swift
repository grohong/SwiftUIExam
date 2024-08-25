//
//  MockNetworkService.swift
//  SwiftUIExamTests
//
//  Created by Hong Seong Ho on 3/27/24.
//

import Foundation
@testable import SwiftUIExam

class MockNetworkService: PicsumNetworkServiceProtocol {

    var shouldReturnError = false
    var fetchedImageList: [PicsumImage]!
    var fetchedImage: PicsumImage!

    enum MockError: Error {
        case testError
    }

    init( shouldReturnError: Bool = false) {
        self.shouldReturnError = shouldReturnError
    }

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage] {
        guard shouldReturnError == false else { throw MockError.testError }
        return fetchedImageList
    }

    func fetchImageDetail(id: String) async throws -> PicsumImage {
        guard shouldReturnError == false else { throw MockError.testError }
        return fetchedImage
    }
}
