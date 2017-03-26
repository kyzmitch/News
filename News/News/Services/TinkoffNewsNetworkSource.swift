//
//  TinkoffNewsNetworkService.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

struct TinkoffNewsNetworkSource: NewsNetworkServiceDataSource {

    private static let baseApiUrlString = "api.tinkoff.ru"
    
    let httpClient = HttpClient(baseApiUrlString: baseApiUrlString)
    let cacheClient = CacheClient()
    
    func fetchNews(completion: @escaping ((NewsNetworkService.Result) -> Void)) {
        httpClient.sendRequest(path: "v1/news", method: .Get) { (data, response, error) in
            if let error = error {
                if let cachedNews = self.cacheClient.fetchNews() {
                    completion(NewsNetworkService.Result.success(cachedNews))
                }
                else{
                    let enumErr = NewsNetworkService.NewsError.networkError(error)
                    completion(NewsNetworkService.Result.failure(enumErr))
                }
            }
            else {
                if let data = data {
                    let parseResponse = TinkoffNewsNetworkSource.ResponseParser.parse(responseData: data)
                    switch parseResponse {
                    case .successArticles(let articles):
                        completion(NewsNetworkService.Result.success(articles))
                        self.cacheClient.saveTinkoffNews(articles: articles)
                    case .failure(_):
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.parseError))
                    default:
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.unknownError))
                    }
                }
                else {
                    let error = NewsNetworkService.NewsError.noDataError
                    completion(NewsNetworkService.Result.failure(error))
                }
            }
        }
    }
    
    func fetchArticleContent(articleId: Int, completion: @escaping ((NewsNetworkService.Result) -> Void)) {
        let path: String = "v1/news_content?id=" + String(articleId)
        
        httpClient.sendRequest(path: path, method: .Get) { (data, response, error) in
            if let error = error {
                if let article = self.cacheClient.fetchArticle(articleId: articleId) {
                    completion(NewsNetworkService.Result.successArticleContent(article))
                }
                else{
                    let enumErr = NewsNetworkService.NewsError.networkError(error)
                    completion(NewsNetworkService.Result.failure(enumErr))
                }
            }
            else {
                if let data = data {
                    let parseResponse = TinkoffNewsNetworkSource.ResponseParser.parse(responseData: data)
                    switch parseResponse {
                    case .successArticleContent(let fullArticle):
                        completion(NewsNetworkService.Result.successArticleContent(fullArticle))
                        self.cacheClient.saveArticle(article: fullArticle)
                    case .failure(_):
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.parseError))
                    default:
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.unknownError))
                    }
                }
                else {
                    let error = NewsNetworkService.NewsError.noDataError
                    completion(NewsNetworkService.Result.failure(error))
                }
            }
        }
    }
}

extension TinkoffNewsNetworkSource {
    class ResponseParser {
        
        enum Result {
            case successArticleContent(FullArticle)
            case successArticles([Article])
            case failure(ResponseParser.Error)
        }
        
        enum Error {
            case unknown
        }
        
        static func parse(responseData data: Data) -> ResponseParser.Result {

            var jsonObject: Any?
            do {
                jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error as NSError {
                print(error.description)
            }
            if let jsonObject = jsonObject {
                if let json = jsonObject as? [String: AnyObject] {
                    if let jsonArticles = json["payload"] as? [AnyObject] {
                        if let payloads = jsonArticles as? [[String: AnyObject]] {
                            var articles = [Article]()
                            for dictionary: [String: AnyObject] in payloads {
                                
                                guard let articleIdString = dictionary["id"] as? String else {
                                    continue
                                }
                                guard let articleId = Int(articleIdString) else {
                                    continue
                                }
                                guard let titleText = dictionary["text"] as? String else {
                                    continue
                                }
                                guard let publicationDateDictionary = dictionary["publicationDate"] as? [String: AnyObject] else {
                                    continue
                                }
                                guard let milliseconds = publicationDateDictionary["milliseconds"] as? Int else {
                                    continue
                                }
                                let publicationDate = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
                                let article = Article(backendId: articleId,
                                                      titleText: String(htmlEncodedString: titleText),
                                                      publicationDate: publicationDate)
                                articles.append(article)
                            }
                            
                            return ResponseParser.Result.successArticles(articles)
                        }
                        
                    }
                    else if let jsonArticleContent = json["payload"] as? [String: AnyObject] {
                        if let titleJson = jsonArticleContent["title"] as? [String: AnyObject]{
                            guard let articleIdString = titleJson["id"] as? String else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            guard let articleId = Int(articleIdString) else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            guard let titleText = titleJson["text"] as? String else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            guard let publicationDateDictionary = titleJson["publicationDate"] as? [String: AnyObject] else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            guard let milliseconds = publicationDateDictionary["milliseconds"] as? Int else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            let publicationDate = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
                            guard let content = jsonArticleContent["content"] as? String else {
                                let error = Error.unknown
                                return ResponseParser.Result.failure(error)
                            }
                            
                            let fullArticle = FullArticle(backendId: articleId,
                                                          titleText: String(htmlEncodedString: titleText),
                                                          publicationDate: publicationDate,
                                                          content: content)
                            
                            return ResponseParser.Result.successArticleContent(fullArticle)
                        }
                    }
                }
            }

            let error = Error.unknown
            return ResponseParser.Result.failure(error)
        }
        
    }
}

extension String {
    init(htmlEncodedString: String) {
        var attributedString: NSAttributedString?
        if let encodedData = htmlEncodedString.data(using: String.Encoding.utf8) {
            let attributedOptions : [String: AnyObject] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
                NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue) as AnyObject
            ]
            attributedString = try? NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        }
        
        if let attributedString = attributedString {
            self.init(attributedString.string)!
        }
        else{
            self.init(htmlEncodedString)!
        }
    }
}
