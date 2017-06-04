//
//  TinkoffNewsCacheSource.swift
//  News
//
//  Created by admin on 04/06/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation
import CoreData

struct TinkoffNewsCacheSource: NewsCacheSource {
    func fetchAllNewsRequest() -> NSFetchRequest<NewsModel> {
        return NewsModel.fetchRequest()
    }
    
    func clearAllNewsForModel(model: NewsModel) {
        // TODO: fix clearing of news, full articles with content text
        // are not removed
        model.tinkoff = nil
    }
    
    func saveArticles(articles: [PONSOArticleModel], to model: NewsModel, on context: NSManagedObjectContext) {
        model.rewriteTinkoffNews(articles: articles, on: context)
    }
    
    func createNewsModel(on context: NSManagedObjectContext) -> NewsModel {
        let newsContainer = NewsModel(context: context)
        return newsContainer
    }
    
    func fetchNews(from model: NewsModel) -> [PONSOFullArticleModel]? {
        let fetchedNews = model.articlesFromTinkoffNews()
        return fetchedNews
    }
    
    typealias NewsModel = CdNews
    typealias PONSOArticleModel = Article
    typealias PONSOFullArticleModel = FullArticle
}
