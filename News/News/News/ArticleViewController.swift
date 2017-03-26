//
//  ArticleViewController.swift
//  News
//
//  Created by Andrey Ermoshin on 25/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit
import WebKit // to show convert html tags for article content

class ArticleViewController: BaseViewController {

    private var articleModel: FullArticleViewModel?
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var contentContainer: UIView!
    private let contentWebView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(handleBackPress))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.articleTitle.layer.borderWidth = 1.0
        self.articleTitle.layer.borderColor = UIColor.black.cgColor
        
        self.contentContainer.addSubview(self.contentWebView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let frame = CGRect(x: 0, y: 0, width: self.contentContainer.frame.size.width, height: self.contentContainer.frame.size.height)
        self.contentWebView.frame =  frame
        
    }

    public func setViewModel(articleFullViewModel: FullArticleViewModel) {
        self.articleModel = articleFullViewModel
    }
    
    func handleBackPress() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.articleTitle.text = self.articleModel?.title()
        if let htmlText = self.articleModel?.contentHtmlText() {
            self.contentWebView.loadHTMLString(htmlText, baseURL: nil)
        }
    }
}
