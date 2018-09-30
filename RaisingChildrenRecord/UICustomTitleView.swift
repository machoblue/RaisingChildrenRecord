//
//  UICustomTitleView.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/29.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import CustomRealmObject

class UICustomTitleView: UIView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var date: UILabel!
    
    var baby: Baby?
    var day: Date?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
//        loadNib()
//        initViews()
    }
    
    convenience init(frame: CGRect, baby: Baby?, date: Date?) {
        self.init(frame: frame)
        self.baby = baby
        self.day = date
        loadNib()
        initViews()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("CustomTitleView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func initViews() {

        if let unwrappedBaby = baby, let unwrappedDay = day {
            self.name.text = unwrappedBaby.name
//            self.image.image = UIImage(named: unwrappedBaby.female ? "temperature" : "milk")
            self.date.text = format(date: unwrappedDay)
            self.year.text = resolveAge(born: unwrappedBaby.born, now: unwrappedDay)

        } else {
            self.name.text = "たろう"
            self.year.text = "1歳6ヶ月"
            self.date.text = "2018年7月29日"
        }
    }
    
    func format(date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .long
        f.timeStyle = .none
        return f.string(from: date)
    }
    
    func resolveAge(born: Date, now: Date) -> String? {
        let timeInterval = now.timeIntervalSince(born)
        let f = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja")
        f.calendar = calendar
        f.unitsStyle = .full
        f.allowedUnits = [.year, .month]
        var formatted = f.string(from: timeInterval)
        if let range = formatted?.range(of: "年") {
            formatted?.replaceSubrange(range, with: "歳")
        }
        return "(" + formatted! + ")"
    }
    
}
