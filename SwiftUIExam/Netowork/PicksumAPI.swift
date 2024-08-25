//
//  PicksumAPI.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

enum PicsumAPI {

    case list(page: Int, limit: Int)
    case detail(id: String)

    var baseURL: URL? {
        return URL(string: "https://picsum.photos")
    }

    var path: String {
        switch self {
        case .list:
            return "/v2/list"
        case .detail(let id):
            return "/id/\(id)/info"
        }
    }

    var url: URL? {
        guard let baseURL else { return nil }
        switch self {
        case .list(let page, let limit):
            var components = URLComponents(
                url: baseURL.appendingPathComponent(path),
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            return components?.url
        case .detail:
            return baseURL.appendingPathComponent(path)
        }
    }
}
