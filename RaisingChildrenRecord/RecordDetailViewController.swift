//
//  RecordDetailViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/12/15.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit
import IntentsUI

import os.log

import Shared

class RecordDetailViewController: UIViewController {
    
    private(set) var record: RecordModel!
    
    private var tableConfig: RecordDetailTableConfiguration!
    
    private weak var dateTimeButton: UIButton?
    private weak var datePicker: UIDatePicker?
    private weak var deleteButton: UIButton?
    private weak var quantityLabel: UILabel?
    private weak var noteTextField: UITextField?
    
    private let f = DateFormatter()
    
    private var hideDatePicker = true

    @IBOutlet weak var tableView: UITableView!

    private weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleBar: UINavigationItem!
    private var titleStr: String!
    
    @IBOutlet var tableFooterView: UIView!
    
    private var recordDao: RecordDao!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleBar.title = titleStr
//        tableView.allowsSelection = false
        configureTableFooterView()
        
        // Do any additional setup after loading the view.
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        
        recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
    }
    
    func configure(record: RecordModel) {
        self.record = record
        var recordType: RecordDetailTableConfiguration.RecordType? = nil
        if (record.commandId == "1") {
            recordType = .milk
        }
        if (record.commandId == "2") {
            recordType = .breast
        }
        if (record.commandId == "3") {
            recordType = .babyfood
        }
        if (record.commandId == "4") {
            recordType = .snack
        }
        if (record.commandId == "5") {
            recordType = .temperature
        }
        if (record.commandId == "6") {
            recordType = .poo
        }
        if (record.commandId == "7") {
            recordType = .sleep
        }
        if (record.commandId == "8") {
            recordType = .awake
        }
        if (record.commandId == "9") {
            recordType = .medicine
        }
        if (record.commandId == "99") {
            recordType = .other
        }
        
        self.tableConfig = RecordDetailTableConfiguration(recordType: recordType!)
        titleStr = Command.name(id: Int(record.commandId!)!)
    }
    
    /// - Tag: add_to_siri_button
    private func configureTableFooterView() {
            let addShortcutButton = INUIAddVoiceShortcutButton(style: .whiteOutline)
            addShortcutButton.shortcut = INShortcut(intent: record.intent)
            addShortcutButton.delegate = self
        
            addShortcutButton.translatesAutoresizingMaskIntoConstraints = false
            tableFooterView.addSubview(addShortcutButton)
            tableFooterView.centerXAnchor.constraint(equalTo: addShortcutButton.centerXAnchor).isActive = true
            tableFooterView.centerYAnchor.constraint(equalTo: addShortcutButton.centerYAnchor).isActive = true
        
            tableView.tableFooterView = tableFooterView
    }
    
    @IBAction private func onStepperChanged(_ sender: UIStepper) {
        record.value2 = Int(sender.value).description
        quantityLabel?.text = record.value2! + "ml"
    }
    
    @IBAction private func onStepperChanged2(_ sender: UIStepper) {
        record.value2 = Int(sender.value).description
        quantityLabel?.text = record.value2! + "分"
    }
    
    @IBAction private func onStepperChanged3(_ sender: UIStepper) {
        record.value2 = (round(Double(sender.value) * 10) / 10).description
        quantityLabel?.text = record.value2! + "℃"
    }
    
    @IBAction private func onDateTimeButtonClicked(_ sender: UIButton) {
        print("*** RecordDetailViewControler.onDateTimeButtonClicked ***")
        hideDatePicker = !hideDatePicker
        tableView.reloadData()
    }
    
    @IBAction private func onDeleteButtonClicked(_ sender: UIButton) {
        print("*** RecordDetailViewControler.onDeleteButtonClicked ***")
        recordDao.delete(record)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onBackButtonClicked(_ sender: Any) {
        print("*** RecordDetailViewControler.onBackButtonClicked ***")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonClicked(_ sender: Any) {
        print("*** RecordDetailViewControler.onSaveButtonClicked ***")
        recordDao.insertOrUpdate(record)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onValueChanged(sender: UIDatePicker!) {
        self.record.dateTime = sender.date
        dateTimeButton?.setTitle(f.string(from: self.record.dateTime!), for: .normal)
    }
    
    @IBAction func onTextFieldChanged(sender: UITextField!) {
        self.record.value1 = sender.text
    }
    
}

extension RecordDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableConfig.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableConfig.sections[section].type.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableConfig.sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = tableConfig.sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionModel.cellReuseIdentifier, for: indexPath)
        configure(cell: cell, at: indexPath, with: sectionModel)
        return cell
    }
    
    private func configure(cell: UITableViewCell, at indexPath: IndexPath, with sectionModel: RecordDetailTableConfiguration.SectionModel) {
        switch sectionModel.type {
        case .dateTime:
            if let cell = cell as? DateTimeTableViewCell {
                dateTimeButton = cell.button
                dateTimeButton?.setTitle(title, for: .normal)
                dateTimeButton?.setTitle(f.string(from: record.dateTime!), for: .normal)
                dateTimeButton?.addTarget(self, action: #selector(onDateTimeButtonClicked), for: .touchUpInside)

                datePicker = cell.datePicker
                datePicker?.timeZone = NSTimeZone.local
                datePicker?.locale = Locale(identifier: "en_US") // en_US?
                datePicker?.date = record.dateTime!
                datePicker?.addTarget(self, action: #selector(onValueChanged), for: .valueChanged)
                
                datePickerHeightConstraint = cell.datePickerHeightConstraint
                datePickerHeightConstraint.constant = hideDatePicker ? 0 : 216
                
            }
        case .deleteButton:
            if let cell = cell as? DeleteButtonTableViewCell {
                cell.button.setTitle("削除する", for: .normal)
                cell.button.addTarget(self, action: #selector(onDeleteButtonClicked), for: .touchUpInside)
            }
            break
        case .note:
            if let cell = cell as? TextTableViewCell {
                noteTextField = cell.textField
                noteTextField!.layer.cornerRadius = 10
                noteTextField!.text = record.value1
                noteTextField!.addTarget(self, action: #selector(onTextFieldChanged), for: .editingChanged)
            }
            break
        case .milliLitters:
            if let cell = cell as? QuantityTableViewCell {
                cell.stepper.stepValue = 10
                cell.stepper.minimumValue = 0
                cell.stepper.maximumValue = 500
                
                if record.value2 == nil || record.value2 == "" {
                    record.value2 = 100.description
                }
                
                cell.stepper.value = Double(record.value2!)!
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged(_:)), for: .valueChanged)
                
                quantityLabel = cell.label
                quantityLabel?.text = record.value2! + "ml"
            }
        case .minutes:
            if let cell = cell as? QuantityTableViewCell {
                cell.stepper.stepValue = 5
                cell.stepper.minimumValue = 0
                cell.stepper.maximumValue = 60
                
                if record.value2 == nil || record.value2 == "" {
                    record.value2 = 10.description
                }
                
                cell.stepper.value = Double(record.value2!)!
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged2(_:)), for: .valueChanged)
                
                quantityLabel = cell.label
                quantityLabel?.text = record.value2! + "分"
            }
        case .temperature:
            if let cell = cell as? QuantityTableViewCell {
                cell.stepper.stepValue = 0.1
                cell.stepper.minimumValue = 34.0
                cell.stepper.maximumValue = 42.0
                
                if record.value2 == nil || record.value2 == "" {
                    record.value2 = 37.0.description
                }
                
                cell.stepper.value = Double(record.value2!)!
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged3(_:)), for: .valueChanged)
                
                quantityLabel = cell.label
                quantityLabel?.text = record.value2! + "℃"
            }
        case .hardness:
            if record.value2 == nil || record.value2 == "" {
                record.value2 = "normal"
            }

            let option = Command.HardnessOption.all[indexPath.row]
            cell.textLabel?.text = option.label
            cell.accessoryType = option.rawValue == record.value2 ? .checkmark : .none
        case .amount:
            if record.value3 == nil || record.value3 == "" {
                record.value3 = "normal"
            }
            
            let option = Command.AmountOption.all[indexPath.row]
            cell.textLabel?.text = option.label
            cell.accessoryType = option.rawValue == record.value3 ? .checkmark : .none
        }
    }
    
}

extension RecordDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        let isDateTimeCell = section == 0 && row == 0
        if (isDateTimeCell && !hideDatePicker) {
            return 266
        }

        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
            let cellText = cell.textLabel?.text else {return}
        
        let section = indexPath.section
        let sectionModel: RecordDetailTableConfiguration.SectionModel = tableConfig.sections[section]
        if sectionModel.type == RecordDetailTableConfiguration.SectionType.hardness {
            if Command.HardnessOption(rawValue: record.value2!)?.label == cellText {
            } else {
                for row in 0..<tableConfig.sections[indexPath.section].rowCount {
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section))
                    cell?.accessoryType = .none
                }
                
                cell.accessoryType = .checkmark
                
                record.value2 = Command.HardnessOption.all[indexPath.row].rawValue
            }
            
        } else if sectionModel.type == RecordDetailTableConfiguration.SectionType.amount {
            if Command.AmountOption(rawValue: record.value3!)?.label == cellText {
            } else {
                for row in 0..<tableConfig.sections[indexPath.section].rowCount {
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section))
                    cell?.accessoryType = .none
                }

                cell.accessoryType = .checkmark

                record.value3 = Command.AmountOption.all[indexPath.row].rawValue
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RecordDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
}

extension RecordDetailViewController: INUIAddVoiceShortcutButtonDelegate {
    
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    /// - Tag: edit_phrase
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
}

extension RecordDetailViewController: INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                        didFinishWith voiceShortcut: INVoiceShortcut?,
                                        error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension RecordDetailViewController: INUIEditVoiceShortcutViewControllerDelegate {
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didUpdate voiceShortcut: INVoiceShortcut?,
                                         error: Error?) {
        if let error = error as NSError? {
            os_log("Error adding voice shortcut: %@", log: OSLog.default, type: .error, error)
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController,
                                         didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

class DateTimeTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
}

class DatePickerTableViewCell: UITableViewCell {
    @IBOutlet weak var datePicker: UIDatePicker!
}

class TextTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

class DeleteButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
}

class QuantityTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stepper: UIStepper!
}
