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

    func loadImage(from url: URL) async -> (URL, UIImage)? {

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            return (url, image)
        } catch {
            return nil
        }
    }
}
