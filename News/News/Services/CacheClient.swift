//
//  CacheClient.swift
//  News
//
//  Created by Andrey Ermoshin on 26/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation
import CoreData

struct CacheClient {
    
    func saveTinkoffNews(articles: [Article]) {
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.perform {
            let newsRequest: NSFetchRequest<CdNews> = CdNews.fetchRequest()
            if let newsArray = try? context.fetch(newsRequest) as [CdNews] {
                if newsArray.count > 0 {
                    let newsContainer = newsArray[0]
                    if let tinkoffNews = newsContainer.tinkoff {
                        newsContainer.removeFromTinkoff(tinkoffNews)
                    }
                    newsContainer.rewriteTinkoffNews(articles: articles, on: context)
                }
                else{
                    let newsContainer = CdNews(context: context)
                    newsContainer.rewriteTinkoffNews(articles: articles, on: context)
                }
            }
            else{
                let newsContainer = CdNews(context: context)
                newsContainer.rewriteTinkoffNews(articles: articles, on: context)
            }
            
            try? context.save()
        }
    }
    
    func fetchNews() -> [FullArticle]?  {
        var fetchedNews: [FullArticle]?
        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let newsRequest: NSFetchRequest<CdNews> = CdNews.fetchRequest()
            if let newsArray = try? context.fetch(newsRequest) as [CdNews] {
                if newsArray.count > 0 {
                    let newsContainer = newsArray[0]
                    fetchedNews = newsContainer.articlesFromTinkoffNews()
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
