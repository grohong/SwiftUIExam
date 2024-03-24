//
//  PicsumNetworkProtocol.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

protocol PicsumNetworkProtocol {

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage]
}

actor PicsumNetwork: PicsumNetworkProtocol {

    static let shared = PicsumNetwork()

    private init() {}

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage] {
        guard let imageListURL = PicsumAPI.list(page: page, limit: limit).url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: imageListURL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            let imageList = try JSONDecoder().decode([PicsumImage].self, from: data)
            return imageList
        } catch {
            throw URLError(.cannotParseResponse)
        }
    }
}
