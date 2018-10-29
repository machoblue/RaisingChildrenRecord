//
//  PickerViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/28.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class PickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sections: [(header: String, cells: [String])] = []

    // MARK: - UIViewController Lifecycle Callback
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** PickerViewController.viewDidLoad ***", sections)
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        label.text = self.sections[indexPath.section].cells[indexPath.row]
        print("*** PickerViewController.tableView ***", label.text)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].header
    }
    
    
    // MARK: - UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let userInfoDict = ["selectedIndex": indexPath.row]
        NotificationCenter.default.post(name: .PickerItemSelected, object: nil, userInfo: userInfoDict)
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    // MARK: - Event
    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension Notification.Name {
    static let PickerItemSelected = Notification.Name("PickerItemSelected")
}
