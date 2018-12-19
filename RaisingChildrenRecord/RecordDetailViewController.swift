//
//  RecordDetailViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/12/15.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import Shared

class RecordDetailViewController: UIViewController {
    
    private(set) var record: RecordModel!
    
    private var tableConfig = RecordDetailTableConfiguration(recordType: .sleep)
    
    private weak var dateTimeButton: UIButton?
    private weak var deleteButton: UIButton?
    private weak var quantityLabel: UILabel?
    private weak var noteTextField: UITextField?
    
    private let f = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func configure(record: RecordModel) {
        self.record = record
        var recordType: RecordDetailTableConfiguration.RecordType? = nil
//        if (record.commandId == "1") {
//            recordType = .milk
//        }
//        if (record.commandId == "2") {
//            recordType = .breast
//        }
//        if (record.commandId == "3") {
//            recordType = .temperature
//        }
//        if (record.commandId == "4") {
//            recordType = .poo
//        }
        if (record.commandId == "5") {
            recordType = .sleep
        }
//        if (record.commandId == "6") {
//            recordType = .awake
//        }
//        if (record.commandId == "7") {
//            recordType = .other
//        }
        
        self.tableConfig = RecordDetailTableConfiguration(recordType: recordType!)
    }
    
    @IBAction private func onStepperChanged(_ sender: UIStepper) {
        print("*** RecordDetailViewControler.stepperChanged ***")
    }
    
    @IBAction private func onDateTimeButtonClicked(_ sender: UIButton) {
        print("*** RecordDetailViewControler.onDateTimeButtonClicked ***")
    }
    
    @IBAction private func onDeleteButtonClicked(_ sender: UIButton) {
        print("*** RecordDetailViewControler.onDeleteButtonClicked ***")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onBackButtonClicked(_ sender: Any) {
        print("*** RecordDetailViewControler.onBackButtonClicked ***")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSaveButtonClicked(_ sender: Any) {
        print("*** RecordDetailViewControler.onSaveButtonClicked ***")
        dismiss(animated: true, completion: nil)
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
            print("*** RecordDetailViewController.configure case .dateTime ***")
            if let cell = cell as? DateTimeTableViewCell {
                dateTimeButton = cell.button
                let title = record.dateTime == nil ? "dateTime is nil" : f.string(from: record.dateTime!)
                print("*** RecordDetailViewController.configure case .dateTime ***:", title)
                dateTimeButton?.setTitle(title, for: .normal)
//                dateTimeButton?.setTitle(f.string(from: record.dateTime!), for: .normal)
                dateTimeButton?.addTarget(self, action: #selector(onDateTimeButtonClicked), for: .touchUpInside)
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
                // TODO: RecordModelのメモの値をnoteTextFieldに設定する
            }
            break
        case .milliLitters:
            if let cell = cell as? QuantityTableViewCell {
                quantityLabel = cell.label
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged(_:)), for: .valueChanged)
            }
        case .minutes:
            if let cell = cell as? QuantityTableViewCell {
                quantityLabel = cell.label
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged(_:)), for: .valueChanged)
            }
        case .temperature:
            if let cell = cell as? QuantityTableViewCell {
                quantityLabel = cell.label
                cell.stepper.addTarget(self, action: #selector(RecordDetailViewController.onStepperChanged(_:)), for: .valueChanged)
            }
        case .hardness:
            break
        case .amount:
            break
        }
    }
    
}

extension RecordDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = indexPath.section
//        let row = indexPath.row
        return 60
    }
}

class DateTimeTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
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
