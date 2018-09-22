//
//  EditMilkViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/17.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

class EditMilkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var id: String?
    var selected = false
    var record: Record?
    let f = DateFormatter()
    var button: UIButton!
    var currentDateTime: Date!
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath)
            
            self.button = cell.contentView.viewWithTag(1) as! UIButton
            if let currentDateTime = self.currentDateTime {
                self.button.setTitle(f.string(from: currentDateTime), for: .normal)
            } else {
                self.button.setTitle(f.string(from: record!.dateTime!), for: .normal)
            }
            self.button.addTarget(self, action: #selector(onClicked), for: .touchUpInside)

        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath)
            
            let datePicker = cell.contentView.viewWithTag(1) as! UIDatePicker
            datePicker.timeZone = NSTimeZone.local
            datePicker.locale = Locale(identifier: "en_US") // en_USいいのか
            if let currentDateTime = self.currentDateTime {
                datePicker.date = currentDateTime
            } else {
                datePicker.date = record!.dateTime!
            }
            datePicker.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)

        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection: Int?
        switch section {
        case 0:
            numberOfRowsInSection = selected ? 2 : 1
        default:
            numberOfRowsInSection = 0
        }
        return numberOfRowsInSection!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "時間帯"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 60
        case 1:
            return 216
        default:
            return 60
        }
    }
    
    @objc func onClicked(sender: UIButton!) {
        selected = selected ? false : true
        tableView.reloadData()
    }
    
    @objc func onValueChanged(sender: UIDatePicker!) {
        self.currentDateTime = sender.date
        button.setTitle(f.string(from: self.currentDateTime), for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        self.record = realm.objects(Record.self).filter("id == %a", self.id!).first
        
        self.currentDateTime = record!.dateTime!
        
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onRightBarButtonClicked(_ sender: Any) {
        let realm = try! Realm()
        try! realm.write {
            record!.dateTime = self.currentDateTime
        }
        dismiss(animated: true, completion: nil)
    }
    
}
