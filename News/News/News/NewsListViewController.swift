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
    internal var newsService: NewsNetworkService!
    internal var model: ArticlesViewModel?
    
    private enum DataMode {
        case loading
        case content(ArticlesViewModel)
    }
    
    private var dataMode: DataMode = .loading
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchNews()
    }
    
    func add(newsService: NewsNetworkService) {
        self.newsService = newsService
    }
    
    private func setup() {
        newsCollectionView.dataSource = self
        newsCollectionView.delegate = self
        
        refreshControl.removeTarget(self, action: nil, for: UIControlEvents.valueChanged)
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        newsCollectionView.addSubview(refreshControl)
        newsCollectionView.alwaysBounceVertical = true
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.minimumLineSpacing = 4
        layout.estimatedItemSize = CGSize(width: 50, height: 50)
        newsCollectionView.collectionViewLayout = layout
    }

    private func updateUi() {
        
        switch self.dataMode {
        case .loading:
            loadingView.alpha = 0
            view.bringSubview(toFront: self.loadingView)
            UIView.animate(withDuration: 1, animations: { [weak self] in
                self?.loadingView.alpha = 1
            })
            break
        case .content(let articlesViewModel):
            self.model = articlesViewModel
            newsCollectionView.reloadData()
            
            let subviewsCount = view.subviews.count
            if subviewsCount > 0 {
                // Determine if it already on top or not
                if view.subviews[subviewsCount - 1] != newsCollectionView {
                    newsCollectionView.alpha = 0
                    view.bringSubview(toFront: newsCollectionView)
                    UIView.animate(withDuration: 1, animations: { [weak self] in
                        self?.newsCollectionView.alpha = 1
                    })
                }
            }
            
            break
        }
    }
    
    private func fetchNews() {
        self.model = nil
        newsCollectionView.reloadData()
        
        newsService.fetchNews { [weak self] (result) in
            
            switch result {
            case .failure( _):
                self?.dataMode = .loading
                break
            case .success(let articles):
                
                if let interfaceIdiom = InterfaceIdiom.interfaceIdiomFrom(uikitInterfaceIdiom: UIDevice.current.userInterfaceIdiom) {
                    let viewModel = ArticlesViewModel(lightArticlesArray: articles,
                                                      interfaceIdiom: interfaceIdiom)
                    self?.dataMode = .content(viewModel)
                }
                
            default:
                self?.dataMode = .loading
                break
            }
            
            DispatchQueue.main.async {
                if let me = self,  me.refreshControl.isRefreshing {
                    me.refreshControl.endRefreshing()
                }
                self?.updateUi()
            }
        }
    }
    
    @objc private func refreshControlAction() {
        fetchNews()
    }
}

extension InterfaceIdiom {
    static func interfaceIdiomFrom(uikitInterfaceIdiom: UIUserInterfaceIdiom) -> InterfaceIdiom? {
        switch uikitInterfaceIdiom {
        case .phone:
            return InterfaceIdiom.phone
        case .pad:
            return InterfaceIdiom.tablet
        default:
            return nil
        }
    }
}
