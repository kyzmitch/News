//
//  NewsServiceHolder.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation

protocol NewsServiceHolder {
    func add(newsService: NewsNetworkService)
}
