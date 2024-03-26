//
//  GridCollectionView.swift
//  SKTChallenge
//
//  Created by Hong Seong Ho on 3/25/24.
//

import SwiftUI
import UIKit

struct GridCollectionView: UIViewRepresentable {

    let imageList: [PicsumImage]
    let fetchMoreAction: () -> Void
    let refreshAction: () async -> Void
    let imageTapAction: (PicsumImage) -> Void

    enum SectionKind {
        case photoList
    }

    typealias DataSource = UICollectionViewDiffableDataSource<SectionKind, PicsumImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionKind, PicsumImage>

    func makeUIView(context: Context) -> UICollectionView {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        collectionView.delegate = context.coordinator

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh(_:)), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        context.coordinator.configureDataSource(for: collectionView)
        return collectionView
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        var snapshot = Snapshot()
        snapshot.appendSections([.photoList])
        snapshot.appendItems(imageList, toSection: .photoList)
        context.coordinator.dataSource?.apply(snapshot, animatingDifferences: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            self,
            fetchMoreAction: fetchMoreAction,
            refreshAction: refreshAction,
            imageTapAction: imageTapAction
        )
    }

    class Coordinator: NSObject, UICollectionViewDelegate {

        private let parent: GridCollectionView

        private let fetchMoreAction: () -> Void
        private let refreshAction: () async -> Void
        private let imageTapAction: (PicsumImage) -> Void
        private var isRefreshing = false

        var dataSource: DataSource?

        init(
            _ parent: GridCollectionView,
            fetchMoreAction: @escaping () -> Void,
            refreshAction: @escaping () async -> Void,
            imageTapAction: @escaping (PicsumImage) -> Void
        ) {
            self.parent = parent
            self.fetchMoreAction = fetchMoreAction
            self.refreshAction = refreshAction
            self.imageTapAction = imageTapAction
        }

        func configureDataSource(for collectionView: UICollectionView) {
            dataSource = DataSource(collectionView: collectionView) {
                (collectionView, indexPath, image) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ImageCell.reuseIdentifier,
                    for: indexPath) as? ImageCell
                cell?.configure(with: image)
                return cell
            }

            var snapshot = Snapshot()
            snapshot.appendSections([.photoList])
            snapshot.appendItems(parent.imageList)
            dataSource?.apply(snapshot, animatingDifferences: false)
        }

        @objc
        func handleRefresh(_ refreshControl: UIRefreshControl) {
            guard isRefreshing == false else { return }

            isRefreshing = true
            Task {
                await refreshAction()
                await MainActor.run {
                    isRefreshing = false
                    refreshControl.endRefreshing()
                }
            }
        }

        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let count = dataSource?.snapshot(for: .photoList).items.count, count - 1 == indexPath.row else { return }
            fetchMoreAction()
        }


        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let items = dataSource?.snapshot(for: .photoList).items else { return }
            imageTapAction(items[indexPath.row])
        }
    }

    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let width = layoutEnvironment.container.effectiveContentSize.width
            let columnCount = width > PhotoListView.Constants.standardWidth ? PhotoListView.Constants.gridColumnCount + 1 : PhotoListView.Constants.gridColumnCount

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columnCount)), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), 
                heightDimension: .fractionalWidth(1.0 * PhotoListView.Constants.gridCellRatio / CGFloat(columnCount))
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columnCount)
            group.interItemSpacing = .fixed(PhotoListView.Constants.gridSpacing)
            group.contentInsets = .init(
                top: .zero,
                leading: PhotoListView.Constants.gridSpacing / 2,
                bottom: PhotoListView.Constants.gridSpacing,
                trailing: PhotoListView.Constants.gridSpacing / 2
            )

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
}

class ImageCell: UICollectionViewCell {

    static let reuseIdentifier = "ImageCell"

    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let retryButton = UIButton(type: .system)

    private var imageURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        retryButton.setTitle("다시 시도하기", for: .normal)
        retryButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        retryButton.tintColor = .label
        retryButton.setTitleColor(.label, for: .normal)
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(handleRetry), for: .touchUpInside)
        contentView.addSubview(retryButton)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            retryButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageURL = nil
        retryButton.isHidden = true
        activityIndicator.stopAnimating()
    }

    func configure(with image: PicsumImage) {
        Task { await load(imageURL: image.downloadURL) }
    }

    private func load(imageURL: URL) async {
        defer { activityIndicator.stopAnimating() }

        self.imageURL = imageURL

        activityIndicator.startAnimating()

        guard let (url, image) = await ImageLoader.shared.loadImage(from: imageURL, loadKind: .resizeWidth(width: bounds.width)) else {
            retryButton.isHidden = false
            return
        }

        guard self.imageURL == url else  { return }
        imageView.image = image
    }

    @objc
    private func handleRetry() {
        guard let url = imageURL else { return }
        retryButton.isHidden = true
        Task { await load(imageURL: url) }
    }
}
