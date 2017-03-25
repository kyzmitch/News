//
//  Storyboard+News.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    enum StoryboardName: String {
        case News = "News"
    }
    static func newsScreen() -> NewsListViewController {
        let storyboard = UIStoryboard(name: StoryboardName.News.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "kNewsListScreenId") as! NewsListViewController
    }
    
    static func articleScreen() -> ArticleViewController {
        let storyboard = UIStoryboard(name: StoryboardName.News.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "kArticleScreenId") as! ArticleViewController
    }
}
