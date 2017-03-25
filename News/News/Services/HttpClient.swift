//
//  HttpClient.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

enum HttpMethod: String {
    case Get = "GET"
    case Post = "POST"
}

class HttpClient: NSObject, URLSessionDelegate {

    private var apiUrl: URL!
    private var session: URLSession!
    private static let defaultTimeout: TimeInterval = 10
    
    init(baseApiUrlString: String) {
        super.init()
        apiUrl = URL(string: "https://" + baseApiUrlString)
        session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: self, delegateQueue: nil)
    }
    
    public func sendRequest(path: String, method: HttpMethod, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let fullPath = apiUrl.absoluteString + "/" + path
        let fullUrl = URL(string: fullPath)
        guard let url = fullUrl else {
            completionHandler(nil, nil, nil)
            return
        }
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: HttpClient.defaultTimeout)
        
        request.addValue("application/xml,application/json;charset=UTF-8", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        let dataTask = self.session.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
}
