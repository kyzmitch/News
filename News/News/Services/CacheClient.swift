//
//  CacheClient.swift
//  News
//
//  Created by Andrey Ermoshin on 26/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation
import CoreData

protocol NewsCacheSource {
    associatedtype NewsModel: NSFetchRequestResult
    associatedtype ArticleModel: NSFetchRequestResult
    associatedtype PONSOArticleModel
    associatedtype PONSOFullArticleModel
    
    func fetchAllNewsRequest() -> NSFetchRequest<NewsModel>
    func fetchArticleRequest(by identifier: Int) -> NSFetchRequest<ArticleModel>
    func fetchArticleRequest(usingIdFrom fullArticle: PONSOFullArticleModel) -> NSFetchRequest<ArticleModel>
    func clearAllNewsForModel(model: NewsModel) -> Void
    func saveArticles(articles: [PONSOArticleModel], to model:NewsModel, on context: NSManagedObjectContext) -> Void
    func createNewsModel(on context: NSManagedObjectContext) -> NewsModel
    func fetchNews(from model:NewsModel) -> [PONSOFullArticleModel]?
    func firstArticle(from array:[ArticleModel]) -> PONSOFullArticleModel?
    func updateFirstArticle(from array:[ArticleModel], with article:PONSOFullArticleModel) -> Void
    func createArticle(article: PONSOFullArticleModel, on context: NSManagedObjectContext) -> Void
}

struct CacheClient<T: NewsCacheSource> {
    
    private let source: T
    
    init(newsCacheSource: T) {
        source = newsCacheSource
    }
    
    func saveNews(articles: [T.PONSOArticleModel]) {
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.perform {
            let newsRequest = self.source.fetchAllNewsRequest()
            if let newsArray = try? context.fetch(newsRequest) as [T.NewsModel] {
                if newsArray.count > 0 {
                    let newsContainer = newsArray[0]
                    self.source.clearAllNewsForModel(model: newsContainer)
                    self.source.saveArticles(articles: articles, to: newsContainer, on: context)
                }
                else{
                    let newsContainer = self.source.createNewsModel(on: context)
                    self.source.saveArticles(articles: articles, to: newsContainer, on: context)
                }
            }
            else{
                let newsContainer = self.source.createNewsModel(on: context)
                self.source.saveArticles(articles: articles, to: newsContainer, on: context)
            }
            
            try? context.save()
        }
    }
    
    func fetchNews() -> [T.PONSOFullArticleModel]?  {
        var fetchedNews: [T.PONSOFullArticleModel]?
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let newsRequest = self.source.fetchAllNewsRequest()
            if let newsArray = try? context.fetch(newsRequest) as [T.NewsModel] {
                if newsArray.count > 0 {
                    let newsContainer = newsArray[0]
                    fetchedNews = self.source.fetchNews(from: newsContainer)
                }
            }
        }
        
        return fetchedNews
    }
    
    func fetchArticle(articleId: Int) -> T.PONSOFullArticleModel? {
        var fetchedArticle: T.PONSOFullArticleModel?
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let articleRequest = self.source.fetchArticleRequest(by: articleId)
            if let fullArticleArray = try? context.fetch(articleRequest) as [T.ArticleModel] {
                if fullArticleArray.count > 0 {
                    fetchedArticle = self.source.firstArticle(from: fullArticleArray)
                }
            }
        }
        
        return fetchedArticle
    }
    
    func saveArticle(article: T.PONSOFullArticleModel) -> Void {
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            var found: Bool = false
            let articleRequest = self.source.fetchArticleRequest(usingIdFrom: article)
            if let fullArticleArray = try? context.fetch(articleRequest) as [T.ArticleModel] {
                if fullArticleArray.count > 0 {
                    self.source.updateFirstArticle(from: fullArticleArray, with: article)
                    found = true
                }
            }
            
            if found == false {
                self.source.createArticle(article: article, on: context)
            }
            try? context.save()
        }
    }
}
