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

     func loadTestData() throws -> Data {
        guard let path = Bundle(for: type(of: self)).path(forResource: "ImageListMock", ofType: "json") else {
            throw MockError.fileNotFound
        }
        return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
    }
}
