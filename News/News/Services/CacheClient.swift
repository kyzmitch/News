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
            guard let title = cdArticle.title else {
                continue
            }
            guard let date = cdArticle.publicationDate else {
                continue
            }

            let article = FullArticle(backendId: Int(cdArticle.backendId), titleText: title, publicationDate: date as Date, content: cdArticle.content)
            articles.append(article)
        }
        
        return articles
    }
}
