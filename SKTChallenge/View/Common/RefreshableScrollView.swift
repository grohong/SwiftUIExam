//
//  RefreshableScrollView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI

struct RefreshableScrollView<Content: View>: UIViewRepresentable {

    private let onRefresh: () async -> Void
    private let content: Content

    init(
        onRefresh: @escaping () async -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(
            context.coordinator,
            action: #selector(Coordinator.refreshAction),
            for: .valueChanged
        )

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            hostingController.view.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor, constant: 1),
        ])

        context.coordinator.hostingController = hostingController

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onRefresh: onRefresh)
    }

    class Coordinator: NSObject {

        private let onRefresh: () async -> Void
        var hostingController: UIHostingController<Content>?

        init(onRefresh: @escaping () async -> Void) {
            self.onRefresh = onRefresh
        }

        @objc 
        func refreshAction(_ refreshControl: UIRefreshControl) {
            Task {
                await onRefresh()
                await refreshControl.endRefreshing()
            }
        }
    }
}
