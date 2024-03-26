//
//  PicsumImage.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

struct PicsumImage: Identifiable, Equatable, Codable, Hashable {

    let id: String
    let author: String
    let width: Int
    let height: Int
    let imageURL: URL
    let downloadURL: URL

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case imageURL = "url"
        case downloadURL = "download_url"
    }
}

extension Array where Element: Identifiable {

    var uniqueIdArray: [Element] {
        var seenIDs = Set<Element.ID>()
        return filter { element in
            guard seenIDs.contains(element.id) == false else { return false }
            seenIDs.insert(element.id)
            return true
        }
    }
}
