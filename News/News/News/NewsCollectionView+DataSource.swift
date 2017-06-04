//
//  NewsCollectionViewDelegate.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

extension NewsListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func configureArticle(_ cell: ArticleTitleViewCell, at indexPath: IndexPath, on collectionView: UICollectionView) {
        guard let model = model else {
            return
        }
    
        ArticleTitleViewCell.preferredWidth = model.cellPreferredWidth(inside: collectionView.frame)
        
        cell.label.text = model.titleForArticle(indexPath: indexPath)
        let publicationDate = model.publicationDateString(indexPath: indexPath)
        cell.publicationLabel.text = publicationDate
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let model = model else {
            return 0
        }
        return model.sectionsNumber
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model else {
            return 0
        }
        return model.articlesCount(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleTitleViewCell.cellIdentifier, for: indexPath) as! ArticleTitleViewCell
        configureArticle(cell, at: indexPath, on: collectionView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let articleId = self.model?.articleId(indexPath: indexPath) else {
            return
        }
        
        self.newsService.fetchArticle(articleId: articleId) { [weak self] (result) in
            
            switch result {
            case .successArticleContent(let fullArticle):
                DispatchQueue.main.async {
                    let articleScreen = UIStoryboard.articleScreen()
                    articleScreen.setViewModel(articleFullViewModel: FullArticleViewModel(fullArticle: fullArticle))
                    let navigationScreen = UINavigationController(rootViewController: articleScreen)
                    self?.present(navigationScreen, animated: true, completion: nil)
                }
                break
                
            default:
                break
            }
        }
    }
}
