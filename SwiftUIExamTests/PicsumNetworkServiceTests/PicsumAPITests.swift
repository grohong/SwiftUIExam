//
//  PicsumAPITests.swift
//  SwiftUIExamTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest
@testable import SwiftUIExam

class PicsumAPITests: XCTestCase {

    func testURLForList() {
        let page = 1
        let limit = 10

        guard let url = PicsumAPI.list(page: page, limit: limit).url else {
            XCTFail("URL 생성 실패")
            return
        }

        XCTAssertEqual(url, URL(string: "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)"))
    }
}
