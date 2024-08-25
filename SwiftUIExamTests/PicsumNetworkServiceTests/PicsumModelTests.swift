//
//  PicsumModelTests.swift
//  SwiftUIExamTests
//
//  Created by Hong Seong Ho on 3/24/24.
//

import XCTest
@testable import SwiftUIExam

class PicsumModelTests: XCTestCase {

    func testImageListMockData() throws {
        do {
            let data = try loadMockData(file: .imageList)
            let imageList = try JSONDecoder().decode([PicsumImage].self, from: data)
            XCTAssertGreaterThan(imageList.count, 0)
        } catch {
            XCTFail("디코딩 실패 : \(error)")
        }
    }

    func testImageMockData() throws {
        do {
            let data = try loadMockData(file: .image)
            let image = try JSONDecoder().decode(PicsumImage.self, from: data)
            XCTAssertEqual(image.id, "0")
        } catch {
            XCTFail("디코딩 실패 : \(error)")
        }
    }
}
