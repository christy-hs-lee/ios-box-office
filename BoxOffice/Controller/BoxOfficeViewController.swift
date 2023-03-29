//
//  BoxOfficeViewController.swift
//  BoxOffice
//
//  Created by Christy, Hyemory on 2023/03/20.
//

import UIKit

enum Section {
    case main
}

final class BoxOfficeViewController: UIViewController {
    private var boxOffice: BoxOffice?
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, DailyBoxOfficeItem>!
    private let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = Date().showYesterdayDate(format: .existHyphen)

        fetchBoxOffice()
    }
    
    private func fetchBoxOffice() {
        var api = KobisURLRequest(service: .dailyBoxOffice)
        let queryName = "targetDt"
        let queryValue = Date().showYesterdayDate(format: .notHyphen)
        
        api.addQuery(name: queryName, value: queryValue)
        
        let urlRequest = api.request()
        
        networkManager.fetchData(urlRequest: urlRequest, type: BoxOffice.self) { result in
            switch result {
            case .success(let data):
                self.boxOffice = data
                
                DispatchQueue.main.async {
                    self.configureCollectionView()
                    self.configureDataSource()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - BoxOfficeListCell 등록 및 DataSource 설정

extension BoxOfficeViewController {
    private func createListLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: createListLayout())
        view.addSubview(collectionView)
        configureRefreshControl()
    }
    
    private func configureDataSource() {
        guard let items = boxOffice?.result.dailyBoxOfficeList else { return }
        
        let cellRegistration = UICollectionView.CellRegistration<BoxOfficeListCell, DailyBoxOfficeItem> {
            (cell, indexPath, item) in
            cell.update(with: item)
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, DailyBoxOfficeItem>(collectionView: collectionView) {
            (collectionView, indexPath, itemIdentifier) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: itemIdentifier)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, DailyBoxOfficeItem>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot)
    }
}

// MARK: - Refresh

extension BoxOfficeViewController {
    private func configureRefreshControl() {
        let refresh = UIRefreshControl()
        
        refresh.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    @objc private func handleRefreshControl() {
        fetchBoxOffice()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.navigationItem.title = Date().showYesterdayDate(format: .existHyphen)
            self?.collectionView.refreshControl?.endRefreshing()
        }
    }
}
