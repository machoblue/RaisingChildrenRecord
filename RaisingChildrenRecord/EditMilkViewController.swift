//
//  EditMilkViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/17.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import CustomRealmObject

class EditMilkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var sectionGroups: [
        [
            (header: String, sectionType: SectionType, cells: [
                (label: String, height: CGFloat, cellType: CellType, items: [(label: String, value: Float)])
            ])
        ]
    ] = [
        [
            (header: "dummy", sectionType: .Normal, cells: [
                (label: "", height: 60, cellType: CellType.TextCell, items: [])
            ]),
            (header: "dummy", sectionType: .Normal, cells: [
                (label: "", height: 60, cellType: CellType.TextCell, items: [])
            ])
        ],
        [
            (header: "時間帯", sectionType: .Date, cells: [
                (label: "", height: 60, cellType: CellType.DateButtonCell, items: []),
                (label: "", height: 216, cellType: CellType.DatePickerCell, items: [])
            ]),
            (header: "量", sectionType: .Normal, cells: [
                (label: "", height: 60, cellType: CellType.PickerViewCell, items: [])
            ]),
            (header: "", sectionType: .Normal, cells: [
                (label: "削除する", height: 60, cellType: CellType.DeleteButtonCell, items: [])
            ])
        ]
    ]
    
    var id: String!
    var selected = false
    var record: RecordModel!
    let f = DateFormatter()
    var button: UIButton!
    var dateTime: Date!
    var commandId: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    var recordDao: RecordDao!
    
    // MARK: - ViewController Lifecycle callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
        self.record = recordDao.find(id: self.id)
        self.commandId = Int(record.commandId!)

        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        
        self.sectionGroups[1][1].cells[0].items = self.generateItems(from: 0, to: 300, by: 10, unit: "cc")
        self.sectionGroups[1][1].cells[0].label = "200cc"
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPickerItemSelected(notification:)), name: Notification.Name.PickerItemSelected, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView: UITableViewCell!
        let cell = self.sectionGroups[self.commandId][indexPath.section].cells[indexPath.row]
        
        cellView = tableView.dequeueReusableCell(withIdentifier: cell.cellType.rawValue, for: indexPath)
        
        switch cell.cellType {
        case .DateButtonCell:
            guard let dateTime = self.record.dateTime else { return cellView }
            self.button = cellView.contentView.viewWithTag(1) as! UIButton
            self.button.setTitle(f.string(from: dateTime), for: .normal)
            self.button.addTarget(self, action: #selector(onClicked), for: .touchUpInside)
        case .DatePickerCell:
            guard let dateTime = self.record?.dateTime else { return cellView }
            let datePicker = cellView.contentView.viewWithTag(1) as! UIDatePicker
            datePicker.timeZone = NSTimeZone.local
            datePicker.locale = Locale(identifier: "en_US") // en_US?
            datePicker.date = dateTime
            datePicker.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
        case .TextCell:
            let text = cellView.contentView.viewWithTag(1) as! UITextField
        case .PickerViewCell:
            let label = cellView.contentView.viewWithTag(1) as! UILabel
            label.text = cell.label

        case .DeleteButtonCell:
            let deleteButton = cellView.contentView.viewWithTag(1) as! UIButton
            deleteButton.setTitle(cell.label, for: .normal)
            deleteButton.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
        }
        return cellView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isSectionTypeNormal = sectionGroups[self.commandId][section].sectionType == .Normal
        let cellCount = sectionGroups[self.commandId][section].cells.count
        return (isSectionTypeNormal || self.selected) ? cellCount : cellCount - 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionGroups[self.commandId].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionGroups[self.commandId][section].header
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.sectionGroups[self.commandId][indexPath.section].cells[indexPath.row]
        if cell.cellType == .PickerViewCell {
            let storyboard: UIStoryboard = self.storyboard!
            let pickerViewController = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
            var cells: [String] = []
            for item in cell.items{
                cells.append(item.label)
            }
            pickerViewController.sections = [(header: "", cells: cells)]
            self.present(pickerViewController, animated: true, completion: nil)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        return self.sectionGroups[self.commandId][section].cells[row].height
    }
    
    
    // MARK: - Event
    @objc func onClicked(sender: UIButton!) {
        selected = selected ? false : true
        tableView.reloadData()
    }
    
    @objc func onValueChanged(sender: UIDatePicker!) {
        self.record.dateTime = sender.date
        button.setTitle(f.string(from: self.record.dateTime!), for: .normal)
    }
    
    @objc func onDeleteButtonClicked(sender: UIButton!) {
        self.recordDao.delete(self.record)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onRightBarButtonClicked(_ sender: Any) {
        self.recordDao.insertOrUpdate(self.record)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onPickerItemSelected(notification: Notification) -> Void {
        let selectedIndex = notification.userInfo!["selectedIndex"] as! Int
        let newLabel = sectionGroups[1][1].cells[0].items[selectedIndex].label
        self.sectionGroups[1][1].cells[0].label = newLabel
        self.tableView.reloadData()
    }

    
    // MARK: - Utility
    func generateItems(from: Float, to: Float, by: Float, unit: String) -> [(label: String, value: Float)] {
        var items: [(label: String, value: Float)] = []
        for i in stride(from: from, to: to, by: by) {
            items.append((label: "\(i)" + unit, value: i))
        }
        return items
    }
}

enum CellType: String {
    case DateButtonCell
    case DatePickerCell
    case TextCell
    case DeleteButtonCell
    case PickerViewCell
}

enum SectionType {
    case Normal
    case Date
}
