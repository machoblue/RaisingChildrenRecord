//
//  FirstViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationItem2: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.titleView = UICustomTitleView(frame: (self.navigationItem.titleView?.frame)!)
//        let frame: CGRect = (self.navigationItem2.titleView?.frame)!
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

