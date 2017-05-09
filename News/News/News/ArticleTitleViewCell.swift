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
    @IBOutlet weak var publicationDateHeight: NSLayoutConstraint!
    
    public static var preferredWidth: CGFloat?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.black.cgColor
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        
        if let width = ArticleTitleViewCell.preferredWidth {
            self.label.preferredMaxLayoutWidth = width
            self.publicationLabel.preferredMaxLayoutWidth = width
            
            let cellHeight: CGFloat = publicationDateHeight.constant + self.label.intrinsicContentSize.height + 30
            let preferredSize = CGSize(width: width, height: cellHeight)
            
            var layoutFrame = layoutAttributes.frame
            layoutFrame.size = preferredSize
            layoutAttributes.frame = layoutFrame
        }

        return layoutAttributes
    }
}
