//
//  PhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct PhotoListView: View {

    @StateObject var viewModel: PhotoListViewModel

    var body: some View {
        List(viewModel.imageList, id: \.id) { image in
            Text(image.author)
        }
        .onAppear {
            Task {
                await viewModel.fetchImageList()
            }
        }
    }
}

#Preview {
    PhotoListView(viewModel: PhotoListViewModel())
}

