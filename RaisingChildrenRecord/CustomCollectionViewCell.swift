//
//  CustomCollectionViewCell.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/11.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
