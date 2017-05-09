//
//  File.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation
import CoreGraphics

enum InterfaceIdiom: UInt {
    case phone = 0
    case tablet = 1
}

struct ArticlesViewModel {
    
    private let articles: [LightArticleModel]!
    private let padSections = 2
    private let phoneSections = 1
    private let cellHeight: CGFloat = 68.0
    private let interface: InterfaceIdiom
    
    static let formatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "ru") as Locale!
        return formatter
    }()
    
    init(lightArticlesArray: [LightArticleModel], interfaceIdiom: InterfaceIdiom) {
        articles = lightArticlesArray
        interface = interfaceIdiom
        articles.sort { ( left: LightArticleModel, right: LightArticleModel) -> Bool in
            return left.publicationDate.compare(right.publicationDate) == .orderedDescending
        }
    }
    
    public func cellSize(inside collectionViewFrame: CGRect) -> CGSize {
        switch interface {
        case .tablet:
            return CGSize(width: collectionViewFrame.width / 2 * 0.99, height: cellHeight)
        default:
            return CGSize(width: collectionViewFrame.width, height: cellHeight)
        }
    }
    
    public func sectionsCount() -> Int {
        switch interface {
        case .tablet:
            return padSections
        default:
            return phoneSections
        }
    }
    
    public func articlesCount(section: Int = 0) -> Int {
        switch interface {
        case .tablet:
            if section == padSections - 1 {
                let count: Int = articles.count % padSections
                if count == 0 {
                    return articles.count / padSections
                }
                return count
            }
            else{
                let count: Int = articles.count / padSections
                return count
            }
            
        default:
            return articles.count
        }
    }
    
    private func calculateIndex(indexPath: IndexPath) -> Int {
        let sectionCount = articlesCount(section: indexPath.section)
        let index = sectionCount * indexPath.section + indexPath.row
        return index
    }
    
    public func titleForArticle(indexPath: IndexPath) -> String? {
        let index = calculateIndex(indexPath: indexPath)
        
        if index >= articles.count {
            return nil
        }
        else{
            let article = articles[index]
            return article.titleText
        }
    }
    
    public func publicationDateString(indexPath: IndexPath) -> String? {
        let index = calculateIndex(indexPath: indexPath)
        
        if index >= articles.count {
            return nil
        }
        else{
            let article = articles[index]
            return ArticlesViewModel.formatter.string(from: article.publicationDate)
        }
    }
    
    public func articleId(indexPath: IndexPath) -> Int? {
        let index = calculateIndex(indexPath: indexPath)
        
        if index >= articles.count {
            return nil
        }
        else{
            let article = articles[index]
            return article.backendId
        }
    }
}

