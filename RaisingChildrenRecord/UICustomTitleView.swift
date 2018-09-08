//
//  UICustomTitleView.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/29.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class UICustomTitleView: UIView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var date: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
        initViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
        initViews()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("CustomTitleView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func initViews() {
        self.name.text = "たろう"
        self.image.contentMode = .scaleAspectFit
        self.image.image = UIImage(named: "icon")
        self.year.text = "1歳6ヶ月"
        self.date.text = "2018年7月29日"
    }
    
}
