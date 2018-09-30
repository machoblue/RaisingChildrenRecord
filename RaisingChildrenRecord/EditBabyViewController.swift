//
//  EditBabyViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/25.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import CustomRealmObject

import RealmSwift

class EditBabyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var sections: [(header: String, cells: [(label: String, height: CGFloat)])] = [
    (header: "名前", cells: [(label: "", height: 60)]),
    (header: "生年月日", cells: [(label: "", height: 60)]),
    (header: "性別", cells: [(label: "男の子", height: 60), (label: "女の子", height: 60)])
    ]
    
    var baby: Baby!
    @IBOutlet weak var tableView: UITableView!
    var f = DateFormatter()
    var button: UIButton!
    var textField: UITextField!
    
    var name: String!
    var born: Date!
    var female: Bool!
    
    // MARK: - UIViewController LifeCycle Callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.baby {
            sections.append((header: "", cells: [(label: "削除", height: 60)]))
        } else {
            self.baby = Baby()
        }
        
        self.name = self.baby.name
        self.born = self.baby.born
        self.female = self.baby.female

        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
    }
    

    // MARK: - UITAbleViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
            self.textField = cell.viewWithTag(1) as! UITextField
            self.textField.text = self.name
            self.textField.layer.cornerRadius = 0
            self.textField.addTarget(self, action: #selector(onTextFieldValueChanged), for: .editingChanged)
            
        case 1:
            switch row {
            case 0:
                cell = tableView.dequeueReusableCell(withIdentifier: "BornDateTimeCell", for: indexPath)
                self.button = cell.viewWithTag(1) as! UIButton
                self.button.setTitle(f.string(from: self.born), for: .normal)
                self.button.addTarget(self, action: #selector(onDateTimeButtonClicked), for: .touchUpInside)
            
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: "BornDatePickerCell", for: indexPath)
                
                let datePicker = cell.contentView.viewWithTag(1) as! UIDatePicker
                datePicker.timeZone = NSTimeZone.local
                datePicker.locale = Locale(identifier: "en_US")
                datePicker.date = self.born
                datePicker.addTarget(self, action: #selector(onDatePickerValueChanged), for: .valueChanged)
                
            default:
                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
                
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "GenderCell", for: indexPath)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = sections[section].cells[row].label
            
            let check = (self.female && row == 1) || (!self.female && row == 0)
            cell.accessoryType = check ? .checkmark : .none
            
        
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath)
            self.button = cell.viewWithTag(1) as! UIButton
            self.button.setTitle(sections[3].cells[0].label, for: .normal)
            self.button.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
            
        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            for r in 0...1 {
                let c = tableView.cellForRow(at: IndexPath(row: r, section: indexPath.section))
                c!.accessoryType = .none
            }
            let cell = tableView.cellForRow(at: indexPath)
            cell!.accessoryType = .checkmark
            self.female = (indexPath.row == 1)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[indexPath.section].cells[indexPath.row].height
    }
    
    // MARK: - Event
    @objc func onTextFieldValueChanged(sender: UITextField) {
        self.name = sender.text
    }
    
    @objc func onDateTimeButtonClicked(sender: UIButton) {
        if sections[1].cells.count == 1 {
            sections[1].cells.append((label: "", height: 216))
            
        } else if sections[1].cells.count == 2 {
            sections[1].cells.remove(at: 1)
        }
        
        tableView.reloadData()
    }
    
    @objc func onDeleteButtonClicked(sender: UIButton) {
        let realm = try! Realm()
        let target = realm.objects(Baby.self).filter("id == %@", self.baby.id).first
        if let unwrappedTarget = target {
            try! realm.write {
                realm.delete(unwrappedTarget)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDatePickerValueChanged(sender: UIDatePicker!) {
        self.born = sender.date
        self.button.setTitle(f.string(from: self.born), for: .normal)
    }

    @IBAction func onBackButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonClicked(_ sender: Any) {
        self.name = self.textField.text!
    
        let realm = try! Realm()
        try! realm.write {
            let results = realm.objects(Baby.self).filter("id == %@", self.baby.id)
            if results.count == 0 {
                self.baby.born = self.born
                self.baby.name = self.name
                self.baby.female = self.female
                realm.add(baby)
            } else {
                results.first!.born = self.born
                results.first!.name = self.name
                results.first!.female = self.female
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
