//
//  ArticleViewController.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class ArticleViewController: BaseViewController {

    private var article: FullArticle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(handleBackPress))
        self.navigationItem.leftBarButtonItem = backButton
    }

    public func set(articleFullModel: FullArticle) {
        self.article = articleFullModel
    }
    
    func handleBackPress() {
        self.dismiss(animated: true, completion: nil)
    }
}
