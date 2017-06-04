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
    associatedtype PONSOArticleModel
    associatedtype PONSOFullArticleModel
    
    func fetchAllNewsRequest() -> NSFetchRequest<NewsModel>
    func clearAllNewsForModel(model: NewsModel) -> Void
    func saveArticles(articles: [PONSOArticleModel], to model:NewsModel, on context: NSManagedObjectContext) -> Void
    func createNewsModel(on context: NSManagedObjectContext) -> NewsModel
    func fetchNews(from model:NewsModel) -> [PONSOFullArticleModel]?
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
    
    func fetchArticle(articleId: Int) -> FullArticle? {
        var fetchedArticle: FullArticle?
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let articleRequest: NSFetchRequest<CdArticle> = CdArticle.fetchRequest()
            articleRequest.predicate = NSPredicate(format: "backendId = %d && content.length > 0", articleId)
            if let fullArticleArray = try? context.fetch(articleRequest) as [CdArticle] {
                if fullArticleArray.count > 0 {
                    fetchedArticle = fullArticleArray[0].fullArticleObject()
                }
            }
        }
        
        return fetchedArticle
    }
    
    func saveArticle(article: FullArticle) -> Void {
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            var found: Bool = false
            let articleRequest: NSFetchRequest<CdArticle> = CdArticle.fetchRequest()
            articleRequest.predicate = NSPredicate(format: "backendId = %d", article.backendId)
            if let fullArticleArray = try? context.fetch(articleRequest) as [CdArticle] {
                if fullArticleArray.count > 0 {
                    let fetchedArticle = fullArticleArray[0]
                    fetchedArticle.fillInWith(article: article)
                    found = true
                }
            }
            
            if found == false {
                let cdArticle = CdArticle(context: context)
                cdArticle.fillInWith(article: article)
                // attach to news container
                let newsRequest: NSFetchRequest<CdNews> = CdNews.fetchRequest()
                if let newsArray = try? context.fetch(newsRequest) as [CdNews] {
                    if newsArray.count > 0 {
                        let newsContainer = newsArray[0]
                        newsContainer.addToTinkoff(cdArticle)
                    }
                }
            }
            try? context.save()
        }
    }
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
