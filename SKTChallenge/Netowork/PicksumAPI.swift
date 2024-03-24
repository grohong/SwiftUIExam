//
//  PicksumAPI.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

enum PicsumAPI {

    case list(page: Int, limit: Int)

    var baseURL: URL? {
        return URL(string: "https://picsum.photos")
    }

    var path: String {
        switch self {
        case .list:
            return "/v2/list"
        }
    }

    var url: URL? {
        switch self {
        case .list(let page, let limit):
            guard let baseURL else { return nil }
            var components = URLComponents(
                url: baseURL.appendingPathComponent(path),
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            return components?.url
        }
    }
}
