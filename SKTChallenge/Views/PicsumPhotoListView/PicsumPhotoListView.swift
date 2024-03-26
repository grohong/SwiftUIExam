//
//  PicsumPhotoListView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/24/24.
//

import SwiftUI

struct PicsumPhotoListView: View {

    @StateObject var viewModel: PicsumPhotoListViewModel
    @State private var isShowingAutoComplete = false
    @State private var selectedImage: PicsumImage?

    struct Constants {
        static let navigationTitle: String = "Lorem Picsum"
        static let textfieldPlatceHolder: String = "author 검색"
    }

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isFetchLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if let errorMessage = viewModel.errorMessage {
                    NetworkErrorView(errorMessage: errorMessage) {
                        Task { await viewModel.fetchImageList() }
                    }
                } else {
                    VStack {
                        TextField(
                            Constants.textfieldPlatceHolder,
                            text: $viewModel.searchText,
                            onEditingChanged: { isEditing in
                                isShowingAutoComplete = isEditing
                            }
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                        if isShowingAutoComplete == true {
                            List(viewModel.authorList, id: \.self) { author in
                                AuthorItemView(author: author) {
                                    viewModel.searchText = author
                                    isShowingAutoComplete = false
                                    hideKeyboard()
                                }
                            }
                        } else {
                            PhotoListView(
                                imageList: $viewModel.filteredImageList,
                                isFetchMoreLoading: $viewModel.isFetchMoreLoading,
                                fetchMoreAction: {
                                    guard viewModel.searchText.isEmpty == true else { return }
                                    Task { await viewModel.fetchMoreImageList() }
                                },
                                refreshAction: { await viewModel.refreshImageList() },
                                imageTapAction: { selectedImage = $0 }
                            )
                        }
                    }
                }
            }
            .navigationTitle(Constants.navigationTitle)
            .sheet(item: $selectedImage) { image in
                PicsumPhotoView(viewModel: PicsumPhotoViewModel(id: image.id)) 
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PicsumPhotoListView(viewModel: PicsumPhotoListViewModel())
}
