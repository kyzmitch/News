//
//  NewsCollectionViewDelegate.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class NewsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public var model: ArticlesViewModel?

    func configureArticleTitle(_ cell: ArticleTitleViewCell, at indexPath: IndexPath) {
        cell.label.text = self.model?.titleForArticle(number: indexPath.row)
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
        
    }
}
