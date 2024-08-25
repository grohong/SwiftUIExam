//
//  ImageLoader.swift
//  SwiftUIExam
//
//  Created by Hong Seong Ho on 3/26/24.
//

import UIKit

protocol ImageLoaderProtocol {

    func loadImage(from url: URL, loadKind: ImageLoader.LoadKind) async -> (URL, UIImage)?
}

actor ImageLoader: ImageLoaderProtocol {

    static let shared = ImageLoader()

    private let urlSession: URLSession
    private let urlCache: URLCache

    enum LoadKind {
        case resizeWidth(width: CGFloat)
        case origin
    }

    init(urlCache: URLCache = URLCache(memoryCapacity: 100 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: "imageCache")) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = urlCache
        self.urlCache = urlCache
        self.urlSession = URLSession(configuration: sessionConfig)
    }

    func loadImage(from url: URL, loadKind: LoadKind) async -> (URL, UIImage)? {
        switch loadKind {
        case .resizeWidth(let width):
            return await loadWithCacheImage(from: url, width: width)
        case .origin:
            return await loadOriginImage(from: url)
        }
    }

    private func loadWithCacheImage(from url: URL, width: CGFloat) async -> (URL, UIImage)? {
        let scale = await UIScreen.main.scale
        let scaledWidth = width * scale
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)

        if let cachedResponse = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            return (url, image)
        } else {
            do {
                let (data, response) = try await urlSession.data(for: request)
                guard var image = UIImage(data: data) else { return nil }

                let imageData: Data
                if image.size.width > scaledWidth {
                    image = image.resizedImage(toWidth: width) ?? image
                    imageData = image.pngData() ?? data
                } else {
                    imageData = data
                }
                let cachedResponse = CachedURLResponse(response: response, data: imageData)
                urlCache.storeCachedResponse(cachedResponse, for: request)

                return (url, image)
            } catch {
                return nil
            }
        }
    }

    private func loadOriginImage(from url: URL) async -> (URL, UIImage)? {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)

        do {
            let (data, _) = try await urlSession.data(for: request)
            guard let image = UIImage(data: data) else { return nil }
            return (url, image)
        } catch {
            return nil
        }
    }
}

extension UIImage {

    func resizedImage(toWidth width: CGFloat) -> UIImage? {
        let scaleFactor = width / size.width
        let height = size.height * scaleFactor
        let size = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        draw(in: CGRect(origin: .zero, size: size))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizeImage
    }
}
