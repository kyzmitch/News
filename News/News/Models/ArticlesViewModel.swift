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
    
    init(lightArticlesArray: [Article]) {
        articles = lightArticlesArray
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
}
