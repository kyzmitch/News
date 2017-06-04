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
    
    func fetchArticleRequest(by identifier: Int) -> NSFetchRequest<ArticleModel> {
        let articleRequest: NSFetchRequest<ArticleModel> = ArticleModel.fetchRequest()
        articleRequest.predicate = NSPredicate(format: "backendId = %d && content.length > 0", identifier)
        return articleRequest
    }
    
    func fetchArticleRequest(usingIdFrom fullArticle: PONSOFullArticleModel) -> NSFetchRequest<ArticleModel> {
        let articleRequest: NSFetchRequest<ArticleModel> = ArticleModel.fetchRequest()
        articleRequest.predicate = NSPredicate(format: "backendId = %d && content.length > 0", fullArticle.backendId)
        return articleRequest
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
    
    func firstArticle(from array: [ArticleModel]) -> PONSOFullArticleModel? {
        let fetchedArticle = array.first?.fullArticleObject()
        return fetchedArticle
    }
    
    func updateFirstArticle(from array: [ArticleModel], with article: PONSOFullArticleModel) {
        let fetchedArticle = array.first
        fetchedArticle?.fillInWith(article: article)
    }
    
    func createArticle(article: PONSOFullArticleModel, on context: NSManagedObjectContext) {
        let cdArticle = ArticleModel(context: context)
        cdArticle.fillInWith(article: article)
        // attach to news container
        let newsRequest = self.fetchAllNewsRequest()
        if let newsArray = try? context.fetch(newsRequest) as [NewsModel] {
            if newsArray.count > 0 {
                let newsContainer = newsArray.first
                newsContainer?.addToTinkoff(cdArticle)
            }
        }
    }
    
    typealias NewsModel = CdNews
    typealias ArticleModel = CdArticle
    typealias PONSOArticleModel = Article
    typealias PONSOFullArticleModel = FullArticle
}

extension CdNews {
    func rewriteTinkoffNews(articles: [Article], on context: NSManagedObjectContext) {
        for article in articles {
            let cdArticle = CdArticle(context: context)
            cdArticle.backendId = Int64(article.backendId)
            cdArticle.title = article.titleText
            cdArticle.publicationDate = article.publicationDate as NSDate?
            self.addToTinkoff(cdArticle)
        }
    }
    
    func articlesFromTinkoffNews() -> [FullArticle] {
        guard let tinkoffNews = self.tinkoff else {
            return []
        }
        var articles = [FullArticle]()
        for obj in tinkoffNews {
            guard let cdArticle = obj as? CdArticle else {
                continue
            }
            
            if let article = cdArticle.fullArticleObject() {
                articles.append(article)
            }
        }
        
        return articles
    }
}

extension CdArticle {
    func fullArticleObject() -> FullArticle? {
        guard let title = self.title else {
            return nil
        }
        guard let date = self.publicationDate else {
            return nil
        }
        
        let article = FullArticle(backendId: Int(self.backendId), titleText: title, publicationDate: date as Date, content: self.content)
        return article
    }
    
    func fillInWith(article: FullArticle) {
        self.backendId = Int64(article.backendId)
        self.content = article.content
        self.title = article.titleText
        self.publicationDate = article.publicationDate as NSDate?
    }
}
