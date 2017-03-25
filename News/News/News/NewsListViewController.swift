//
//  NewsListViewController.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class NewsListViewController: BaseViewController {

    @IBOutlet weak var newsCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.newsService.fetchNews { [weak self] (result) in
            
            DispatchQueue.main.async {
                switch result {
                case .failure( _):
                    self?.dataMode = .loading
                    break
                case .success(let articles):
                    let viewModel = ArticlesViewModel(lightArticlesArray: articles)
                    self?.dataMode = DataMode.content(viewModel)
                }
                
                self?.updateUi()
            }
        }
    }
    
    public func add(newsService: NewsNetworkService) {
        self.newsService = newsService
    }
    
    private func setup() {
        self.newsCollectionView.dataSource = collectionViewDelegate
        self.newsCollectionView.delegate = collectionViewDelegate
        self.newsCollectionView.reloadData()
    }

    private func updateUi() {
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
            
            self.newsCollectionView.alpha = 0
            self.view.bringSubview(toFront: self.newsCollectionView)
            UIView.animate(withDuration: 1, animations: { 
                self.newsCollectionView.alpha = 1
            })
            break
        }
    }
    
    
    
}
