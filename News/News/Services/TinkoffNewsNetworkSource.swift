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
    
    private let httpClient = HttpClient(baseApiUrlString: baseApiUrlString)
    private let cacheClient = CacheClient<TinkoffNewsCacheSource>(newsCacheSource: TinkoffNewsCacheSource())
    
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
                        self.cacheClient.saveNews(articles: articles)
                    case .failure(let parseError):
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.parseError(parseError)))
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
                    case .failure(let parseError):
                        completion(NewsNetworkService.Result.failure(NewsNetworkService.NewsError.parseError(parseError)))
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
            case failure(ParseError)
        }
        
        static func parse(responseData data: Data) -> ResponseParser.Result {

            var jsonObject: Any?
            do {
                jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            } catch let error as NSError {
                print("\(type(of: self)): serialization error: \(error.description)")
            }
            
            if jsonObject == nil {
                let error = ParseError.emptyJson
                return ResponseParser.Result.failure(error)
            }

            guard let json = jsonObject as? [String: AnyObject]  else {
                let error = ParseError.wrongJsonFormat
                return ResponseParser.Result.failure(error)
            }
            
            switch json["payload"] {
            case let array as [AnyObject]:
                guard let payloads = array as? [[String: AnyObject]]  else {
                    let error = ParseError.notExpectedSubKey
                    return ResponseParser.Result.failure(error)
                }
                
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
                
            case let dictionary as [String: AnyObject]:
                
                guard let titleJson = dictionary["title"] as? [String: AnyObject] else {
                    let error = ParseError.notExpectedSubKey
                    return ResponseParser.Result.failure(error)
                }
                guard let articleIdString = titleJson["id"] as? String else {
                    let error = ParseError.notFullObject
                    return ResponseParser.Result.failure(error)
                }
                guard let articleId = Int(articleIdString) else {
                    let error = ParseError.notFullObject
                    return ResponseParser.Result.failure(error)
                }
                guard let titleText = titleJson["text"] as? String else {
                    let error = ParseError.notFullObject
                    return ResponseParser.Result.failure(error)
                }
                guard let publicationDateDictionary = titleJson["publicationDate"] as? [String: AnyObject] else {
                    let error = ParseError.notExpectedSubKey
                    return ResponseParser.Result.failure(error)
                }
                guard let milliseconds = publicationDateDictionary["milliseconds"] as? Int else {
                    let error = ParseError.notFullObject
                    return ResponseParser.Result.failure(error)
                }
                let publicationDate = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
                guard let content = dictionary["content"] as? String else {
                    let error = ParseError.notFullObject
                    return ResponseParser.Result.failure(error)
                }
                
                let fullArticle = FullArticle(backendId: articleId,
                                              titleText: String(htmlEncodedString: titleText),
                                              publicationDate: publicationDate,
                                              content: content)
                
                return ResponseParser.Result.successArticleContent(fullArticle)
            default:
                let error = ParseError.notExpectedRootKey
                return ResponseParser.Result.failure(error)
            }
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
