//
//  ImageCollectionViewCell.swift
//  Flicker_iOS_search
//
//  Created by Suryakant Sharma-Pro on 06/09/20.
//  Copyright © 2020 Tokopedia. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: CacheImageView!
    
    override func prepareForReuse() {
      super.prepareForReuse()
      imageView.image = #imageLiteral(resourceName: "placeholder")
    }
}
