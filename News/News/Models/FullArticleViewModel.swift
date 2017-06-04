//
//  FullArticleViewModel.swift
//  News
//
//  Created by Andrey Ermoshin on 26/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation

struct FullArticleViewModel {
    private var article: FullArticle!
    
    init(fullArticle: FullArticle) {
        self.article = fullArticle
    }
    
    public func title() -> String {
        return article.titleText
    }
    
    public func contentHtmlText() -> String? {
        
        return self.article.content
    }
}
