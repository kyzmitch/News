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
    static func newsScreen() -> NewsListViewController {
        let storyboardName = "News"
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "kNewsListScreenId") as! NewsListViewController
    }
}
