//
//  NewsListViewController.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class NewsListViewController: BaseViewController, NewsServiceHolder {

    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    let refreshControl = UIRefreshControl()
    private let collectionViewDelegate = NewsCollectionViewDelegate()
    private var newsService: NewsNetworkService!
    
    private enum DataMode {
        case loading
        case content(ArticlesViewModel)
    }
    
    private var dataMode = DataMode.loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateUi()
        fetchNews()
    }
    
    func add(newsService: NewsNetworkService) {
        self.newsService = newsService
        self.collectionViewDelegate.add(newsService: newsService)
    }
    
    private func setup() {
        self.collectionViewDelegate.presentingController = self
        self.newsCollectionView.dataSource = collectionViewDelegate
        self.newsCollectionView.delegate = collectionViewDelegate
        self.newsCollectionView.reloadData()
        
        self.refreshControl.removeTarget(self, action: nil, for: UIControlEvents.valueChanged)
        self.refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        self.newsCollectionView .addSubview(self.refreshControl)
        self.newsCollectionView.alwaysBounceVertical = true
    }

    private func updateUi() {
        self.refreshControl.endRefreshing()
        
        switch self.dataMode {
        case .loading:
            self.loadingView.alpha = 0
            self.view.bringSubview(toFront: self.loadingView)
            UIView.animate(withDuration: 1, animations: { 
                self.loadingView.alpha = 1
            })
            break
        case .content(let articlesViewModel):
            self.collectionViewDelegate.model = articlesViewModel
            self.newsCollectionView.reloadData()
            
            let subviewsCount = self.view.subviews.count
            if subviewsCount > 0 {
                // Determine if it already on top or not
                if self.view.subviews[subviewsCount - 1] != self.newsCollectionView {
                    self.newsCollectionView.alpha = 0
                    self.view.bringSubview(toFront: self.newsCollectionView)
                    UIView.animate(withDuration: 1, animations: {
                        self.newsCollectionView.alpha = 1
                    })
                }
            }
            
            
            break
        }
    }
    
    private func fetchNews() {
        self.collectionViewDelegate.model = nil
        self.newsCollectionView.reloadData()
        
        self.newsService.fetchNews { [weak self] (result) in
            
            switch result {
            case .failure( _):
                self?.dataMode = .loading
                break
            case .success(let articles):
                let viewModel = ArticlesViewModel(lightArticlesArray: articles)
                self?.dataMode = DataMode.content(viewModel)
            default:
                break
            }
            
            DispatchQueue.main.async {
                self?.updateUi()
            }
        }
    }
    
    @objc private func refreshControlAction() {
        fetchNews()
    }
}
