//
//  EditBabyViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/25.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift
import Firebase

import Shared

class EditBabyViewController: InterstitialAdBaseViewController {
    
//    var sections: [(header: String, cells: [(label: String, height: CGFloat)])] = [
//    (header: "名前", cells: [(label: "", height: 50)]),
//    (header: "生年月日", cells: [(label: "", height: 50)]),
//    (header: "性別", cells: [(label: "男の子", height: 50), (label: "女の子", height: 50)])
//    ]
    
    typealias SectionModel = (type: SectionType, title: String, rowCount: Int, cellReuseIdentifier: String)
    var sections: [SectionModel] = [
        SectionModel(.TextField, "名前", 1, "NameCell"),
        SectionModel(.DateTime, "生年月日", 1, "BornDateTimeCell"),
        SectionModel(.Option, "性別", 2, "GenderCell"),
        SectionModel(.Button, "", 1, "DeleteCell")
    ]
    
    enum SectionType: String {
        case TextField
        case DateTime
        case Option
        case Button
    }
    
    var baby: BabyModel!
    @IBOutlet weak var tableView: UITableView!
    var dateTimeButton: UIButton!
    var textField: UITextField!
    var deleteButton: UIButton!
    
    var name: String!
    var born: Date!
    var female: Bool!
    
    var babyDaoLocal: BabyDao!
    var babyDaoRemote: BabyDao!
    
    private var hideDatePicker = true
    private weak var datePickerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - UIViewController LifeCycle Callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = self.baby {
//            sections.append((header: "", cells: [(label: "削除", height: 60)]))
        } else {
            self.baby = BabyModel(id: UUID().description, name: "赤ちゃん", born: Date(), female: false)
        }
        
        self.name = self.baby.name
        self.born = self.baby.born
        self.female = self.baby.female
        
        self.babyDaoLocal = BabyDaoFactory.shared.createBabyDao(.Local)
        self.babyDaoRemote = BabyDaoFactory.shared.createBabyDao(.Remote)
        
        navigationItem.title = baby.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .plain, target: self, action: #selector(onSaveButtonClicked(_:)))
        
        AdUtils.shared.loadAndAddAdView(self)
    }
    
    // MARK: - Event
    @objc func onTextFieldValueChanged(sender: UITextField) {
        self.name = sender.text
    }
    
    @objc func onDateTimeButtonClicked(sender: UIButton) {
        hideDatePicker = !hideDatePicker
        tableView.reloadData()
    }
    
    @objc func onDeleteButtonClicked(sender: UIButton) {
        babyDaoLocal.delete(self.baby)
        babyDaoRemote.delete(self.baby)
        
        self.showInterstitial {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onDatePickerValueChanged(sender: UIDatePicker!) {
        self.born = sender.date
        self.dateTimeButton.setTitle(UIUtils.shared.formatToMediumYYYYMMDD(self.born), for: .normal)
    }

    @IBAction func onBackButtonClicked(_ sender: Any) {
        self.showInterstitial {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func onSaveButtonClicked(_ sender: Any) {
        self.name = self.textField.text!
        let baby = BabyModel(id: self.baby.id, name: self.name, born: self.born, female: self.female)
        babyDaoLocal.insertOrUpdate(baby)
        babyDaoRemote.insertOrUpdate(baby)
        
        self.showInterstitial {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension EditBabyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionModel.cellReuseIdentifier, for: indexPath)
        configure(cell, with: sectionModel, indexPath: indexPath)
        
        return cell
    }
    
    func configure(_ cell: UITableViewCell, with sectionModel: SectionModel, indexPath: IndexPath) {
        switch sectionModel.type {
        case .TextField:
            self.textField = cell.viewWithTag(1) as? UITextField
            self.textField?.text = self.name
            self.textField?.layer.cornerRadius = 0
            self.textField?.addTarget(self, action: #selector(onTextFieldValueChanged), for: .editingChanged)
            
        case .DateTime:
            if let cell = cell as? DateTimeTableViewCell2 {
                self.dateTimeButton = cell.viewWithTag(1) as? UIButton
                self.dateTimeButton?.setTitle(UIUtils.shared.formatToMediumYYYYMMDD(self.born), for: .normal)
                self.dateTimeButton?.addTarget(self, action: #selector(onDateTimeButtonClicked), for: .touchUpInside)
                
                let datePicker = cell.contentView.viewWithTag(2) as! UIDatePicker
                datePicker.timeZone = NSTimeZone.local
                datePicker.date = self.born
                datePicker.addTarget(self, action: #selector(onDatePickerValueChanged), for: .valueChanged)
                
                datePickerHeightConstraint = cell.datePickerHeightConstraints
                datePickerHeightConstraint.constant = hideDatePicker ? 0 : 216
            }
            
            //            switch row {
            //            case 0:
            //                cell = tableView.dequeueReusableCell(withIdentifier: "BornDateTimeCell", for: indexPath)
            //                self.dateTimeButton = cell.viewWithTag(1) as! UIButton
            //                self.dateTimeButton.setTitle(UIUtils.shared.formatToMediumYYYYMMDD(self.born), for: .normal)
            //                self.dateTimeButton.addTarget(self, action: #selector(onDateTimeButtonClicked), for: .touchUpInside)
            //
            //            case 1:
            //                cell = tableView.dequeueReusableCell(withIdentifier: "BornDatePickerCell", for: indexPath)
            //
            //                let datePicker = cell.contentView.viewWithTag(1) as! UIDatePicker
            //                datePicker.timeZone = NSTimeZone.local
            //                datePicker.date = self.born
            //                datePicker.addTarget(self, action: #selector(onDatePickerValueChanged), for: .valueChanged)
            //
            //            default:
            //                cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            //            }
            
            
        case .Option:
            let label = cell.viewWithTag(1) as! UILabel
            label.text = indexPath.row == 0 ? "男の子" : "女の子"
            
            let check = (self.female && indexPath.row == 1) || (!self.female && indexPath.row == 0)
            cell.accessoryType = check ? .checkmark : .none
            
            //        case 2:
            //            cell = tableView.dequeueReusableCell(withIdentifier: "GenderCell", for: indexPath)
            //            let label = cell.viewWithTag(1) as! UILabel
            //            label.text = sections[section].cells[row].label
            //
            //            let check = (self.female && row == 1) || (!self.female && row == 0)
            //            cell.accessoryType = check ? .checkmark : .none
            
        case .Button:
            self.deleteButton = cell.viewWithTag(1) as? UIButton
            self.deleteButton?.setTitle("削除", for: .normal)
            self.deleteButton?.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
            
            //        case 3:
            //            cell = tableView.dequeueReusableCell(withIdentifier: "DeleteCell", for: indexPath)
            //            self.deleteButton = cell.viewWithTag(1) as! UIButton
            //            self.deleteButton.setTitle(sections[3].cells[0].label, for: .normal)
            //            self.deleteButton.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
            //
            //        default:
            //            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
}

extension EditBabyViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 2 {
//            for r in 0...1 {
//                let c = tableView.cellForRow(at: IndexPath(row: r, section: indexPath.section))
//                c!.accessoryType = .none
//            }
//            let cell = tableView.cellForRow(at: indexPath)
//            cell!.accessoryType = .checkmark
//            self.female = (indexPath.row == 1)
//        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = sections[indexPath.section]
        switch sectionModel.type {
        case .TextField:
            // do nothing
            break
        case .DateTime:
            // do nothing
            break
        case .Option:
            for r in 0...1 {
                let c = tableView.cellForRow(at: IndexPath(row: r, section: indexPath.section))
                c!.accessoryType = .none
            }
            let cell = tableView.cellForRow(at: indexPath)
            cell!.accessoryType = .checkmark
            self.female = (indexPath.row == 1)
        case .Button:
            // do nothing
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionModel = sections[indexPath.section]
        return (sectionModel.type == .DateTime && !hideDatePicker) ? 276 : 50
    }
}

class DateTimeTableViewCell2: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeightConstraints: NSLayoutConstraint!
}
