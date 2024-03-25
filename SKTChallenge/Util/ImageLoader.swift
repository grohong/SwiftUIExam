//
//  ImageLoader.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/26/24.
//

import UIKit

protocol ImageLoaderProtocol {

    func loadImage(from url: URL) async -> (URL, UIImage)?
}

actor ImageLoader: ImageLoaderProtocol {

    static let shared = ImageLoader()

    private let urlSession: URLSession
    private let urlCache: URLCache

    init(urlCache: URLCache = URLCache(memoryCapacity: 100 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: "imageCache")) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = urlCache
        self.urlCache = urlCache
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    func loadImage(from url: URL) async -> (URL, UIImage)? {
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)

        if let cachedResponse = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            return (url, image)
        } else {
            do {
                let (data, response) = try await urlSession.data(for: request)
                let cachedResponse = CachedURLResponse(response: response, data: data)
                urlCache.storeCachedResponse(cachedResponse, for: request)
                guard let image = UIImage(data: data) else { return nil }
                return (url, image)
            } catch {
                return nil
            }
        }
    }
}
