//
//  SecondViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let sections: [(header: String, cells: [String])] = [(header: "赤ちゃんを切り替える", cells: ["", ""]),
                                                         (header: "赤ちゃんを編集する", cells:["", "", ""])]

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

