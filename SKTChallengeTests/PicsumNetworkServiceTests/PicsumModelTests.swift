//
//  PicsumModelTests.swift
//  SKTChallengeTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest
@testable import SKTChallenge

class PicsumModelTests: XCTestCase {

    override func setUpWithError() throws {
        do {
            mockData = try loadTestData()
        } catch {
            throw XCTSkip("목 데이터를 찾지 못했습니다: \(error.localizedDescription)")
        }
    }

    var mockData = Data()

    func testDecodePicsumModel() throws {
        do {
            let images = try JSONDecoder().decode([PicsumImage].self, from: mockData)
            XCTAssertGreaterThan(images.count, 0)
        } catch {
            XCTFail("디코딩 실패 : \(error)")
        }
    }
}
