//
//  PicsumNetworkServiceProtocol.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import Foundation

protocol PicsumNetworkServiceProtocol {

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage]
    func fetchImageDetail(id: Int) async throws -> PicsumImage
}

actor PicsumNetworkService: PicsumNetworkServiceProtocol {

    static let shared = PicsumNetworkService()

    private init() {}

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage] {
        guard let imageListURL = PicsumAPI.list(page: page, limit: limit).url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: imageListURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }

        do {
            let imageList = try JSONDecoder().decode([PicsumImage].self, from: data)
            return imageList
        } catch {
            throw URLError(.cannotParseResponse)
        }
    }

    func fetchImageDetail(id: Int) async throws -> PicsumImage {
        guard let imageDetailURL = PicsumAPI.detail(id: id).url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: imageDetailURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }

        do {
            let picsumImage = try JSONDecoder().decode(PicsumImage.self, from: data)
            return picsumImage
        } catch {
            throw URLError(.cannotParseResponse)
        }
    }
}
