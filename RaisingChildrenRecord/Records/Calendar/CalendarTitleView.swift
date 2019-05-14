//
//  CalendarTitleView.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/02/11.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

class CalendarTitleView: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var yearAndMonth: UILabel!
    
    
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
        
//        self.yearAndMonth.text = "yyyyMM"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("CalendarTitleView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
}
