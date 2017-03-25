//
//  File.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation

struct ArticlesViewModel {
    
    private var articles: [Article]!
    static let formatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "ru") as Locale!
        return formatter
    }()
    
    init(lightArticlesArray: [Article]) {
        articles = lightArticlesArray
        articles.sort { ( left: Article, right: Article) -> Bool in
            return left.publicationDate.compare(right.publicationDate) == .orderedDescending
        }
    }
    
    public func count() -> Int {
        return articles.count
    }
    
    public func titleForArticle(number: Int) -> String? {
        if number >= articles.count {
            return nil
        }
        else{
            let article = articles[number]
            return article.titleText
        }
    }
    
    public func publicationDateString(articleNumber: Int) -> String? {
        if articleNumber >= articles.count {
            return nil
        }
        else{
            let article = articles[articleNumber]
            return ArticlesViewModel.formatter.string(from: article.publicationDate)
        }
    }
}

