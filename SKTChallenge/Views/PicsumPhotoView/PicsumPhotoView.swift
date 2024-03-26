//
//  PicsumPhotoView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/26/24.
//

import SwiftUI

struct PicsumPhotoView: View {

    @StateObject var viewModel: PicsumPhotoViewModel

    struct Constants {
        static let navigationTitle: String = "Picsum Photo"
        static let dismissTitle: String = "닫기"
    }

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .scaleEffect(1.5)
                case .failed(let message):
                    NetworkErrorView(errorMessage: message) {
                        Task { await viewModel.fetchImage() }
                    }
                case .success(let image):
                    GeometryReader { geometry in
                        let screenWidth = geometry.size.width
                        let height = (screenWidth / CGFloat(image.width)) * CGFloat(image.height)
                        ScrollView {
                            VStack {
                                AsyncImageView(
                                    viewModel: .init(
                                        url: image.downloadURL,
                                        loadKind: .origin
                                    )
                                )
                                .frame(width: screenWidth, height: height)

                                Text("Author: \(image.author)")
                                    .font(.title)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle(Text(Constants.navigationTitle), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(
                    action: { presentationMode.wrappedValue.dismiss() }
                ) { Text(Constants.dismissTitle) }
            )
        }
    }
}

#Preview {
    PicsumPhotoView(viewModel: PicsumPhotoViewModel(id: "0"))
}
