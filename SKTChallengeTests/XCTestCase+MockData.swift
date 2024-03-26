//
//  XCTestCase+MockData.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest

extension XCTestCase {

    enum MockError: Error {
        case fileNotFound
    }

    enum MockFileKind {
        case imageList
        case fetchMoreImageList
        case image

        var name: String {
            switch self {
            case .imageList:
                return "ImageListMock"
            case .fetchMoreImageList:
                return "FetchMoreImageListMock"
            case .image:
                return "PicsumImageMock"
            }
        }
    }

    func loadMockData(file: MockFileKind) throws -> Data {
        guard let path = Bundle(for: type(of: self)).path(forResource: file.name, ofType: "json") else {
            throw MockError.fileNotFound
        }
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
}
