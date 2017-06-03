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

struct HttpClient {

    private let apiUrl: URL!
    private let session: URLSession!
    private let defaultTimeout: TimeInterval = 10
    
    init(baseApiUrlString: String) {
        apiUrl = URL(string: "https://" + baseApiUrlString)
        session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: nil)
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
                                 timeoutInterval: self.defaultTimeout)
        
        request.addValue("application/xml,application/json;charset=UTF-8", forHTTPHeaderField: "Accept")
        request.httpMethod = method.rawValue
        let dataTask = self.session.dataTask(with: request, completionHandler: completionHandler)
        dataTask.resume()
    }
}
