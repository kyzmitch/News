//
//  NewsNetworkService.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation

protocol NewsNetworkServiceDataSource {
    func fetchNews(completion: @escaping ((NewsNetworkService.Result) -> Void))
    func fetchArticleContent(articleId: Int, completion: @escaping ((NewsNetworkService.Result) -> Void))
}

struct NewsNetworkService {
    
    enum Result {
        case success([Article])
        case failure(NewsNetworkService.Error)
    }
    
    enum Error {
        case unknownError
        case noDataError
        case parseError
        case networkError(NSError)
    }
    
    let dataSource: NewsNetworkServiceDataSource
    
    init(dataSource: NewsNetworkServiceDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchNews(completion: @escaping (_ result: NewsNetworkService.Result) -> Void) {
        dataSource.fetchNews(completion: completion)
    }
    
    func fetchArticle(articleId: Int, completion: @escaping (_ result: NewsNetworkService.Result) -> Void)  {
        dataSource.fetchArticleContent(articleId: articleId, completion: completion)
    }
    
}
