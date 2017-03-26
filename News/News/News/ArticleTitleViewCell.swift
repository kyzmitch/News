//
//  ArticleTitleViewCell.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

class ArticleTitleViewCell: UICollectionViewCell {
    static let cellIdentifier = "kArticleTitleCellId"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var publicationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }
}
