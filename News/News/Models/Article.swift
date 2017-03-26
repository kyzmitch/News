//
//  Article.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation

protocol LightArticleModel {
    var backendId: Int { get }
    var titleText: String { get }
    var publicationDate: Date { get }
}

protocol ArticleContentDataModel {
    var content: String? { get }
}

struct Article: LightArticleModel {
    let backendId: Int
    let titleText: String
    let publicationDate: Date
}

struct FullArticle: LightArticleModel, ArticleContentDataModel {

    let backendId: Int
    let titleText: String
    let publicationDate: Date
    
    var content: String?
}
