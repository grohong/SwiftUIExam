//
//  SKTChallengeApp.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

@main
struct SKTChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            PicsumPhotoListView(viewModel: PicsumPhotoListViewModel())
        }
    }
}
