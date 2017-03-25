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
    
    func fetchNews(completion: @escaping ((NewsNetworkService.Result) -> Void)) {
        httpClient.sendRequest(path: "v1/news", method: .Get) { (data, response, error) in
            if let data = data {
                let parseResponse = TinkoffNewsNetworkSource.ResponseParser.parse(responseData: data)
                switch parseResponse {
                case .successArticles(let articles):
                    completion(NewsNetworkService.Result.success(articles))
                case .failure(_):
                    completion(NewsNetworkService.Result.failure(NewsNetworkService.Error.parseError))
                }
            }
            else {
                let error = NewsNetworkService.Error.noDataError
                completion(NewsNetworkService.Result.failure(error))
            }
        }
    }
    
    func fetchArticleContent(articleId: Int, completion: @escaping ((NewsNetworkService.Result) -> Void)) {
        let path: String = "news_content?id=" + String(articleId)
        
        // Need implement
    }
}

extension TinkoffNewsNetworkSource {
    class ResponseParser {
        
        enum Result {
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
                                let article = Article(backendId: articleId, titleText: String(htmlEncodedString: titleText))
                                articles.append(article)
                            }
                            
                            return ResponseParser.Result.successArticles(articles)
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
