//
//  NewsCollectionViewDelegate.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class NewsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, NewsServiceHolder {
    
    public var model: ArticlesViewModel?
    private var newsService: NewsNetworkService!
    public weak var presentingController: UIViewController?
    
    func add(newsService: NewsNetworkService) {
        self.newsService = newsService
    }

    func configureArticleTitle(_ cell: ArticleTitleViewCell, at indexPath: IndexPath) {
        cell.label.text = self.model?.titleForArticle(number: indexPath.row)
        let publicationDate = self.model?.publicationDateString(articleNumber: indexPath.row)
        cell.publicationLabel.text = publicationDate
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = self.model else {
            return 0
        }
        return model.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleTitleViewCell.cellIdentifier, for: indexPath) as! ArticleTitleViewCell
        configureArticleTitle(cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let articleId = self.model?.articleIdFor(index: indexPath.row) else {
            return
        }
        if articleId == -1 {
            return
        }
        self.newsService.fetchArticle(articleId: articleId) { [weak self] (result) in
            
            switch result {
            case .successArticleContent(let fullArticle):
                DispatchQueue.main.async {
                    let articleScreen = UIStoryboard.articleScreen()
                    articleScreen.setViewModel(articleFullViewModel: FullArticleViewModel(fullArticle: fullArticle))
                    let navigationScreen = UINavigationController(rootViewController: articleScreen)
                    self?.presentingController?.present(navigationScreen, animated: true, completion: nil)
                }
                break
                
            default:
                break
            }
        }
    }
}
