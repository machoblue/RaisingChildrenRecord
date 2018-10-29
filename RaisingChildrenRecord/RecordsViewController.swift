//
//  RecordsViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/09.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import CustomRealmObject

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var date: Date?
    
    var records: [RecordModel] = []

    @IBOutlet weak var tableView: UITableView!
    
    var recordObserver: RecordObserver!
    
    // MARK: - ViewController lifecycle callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordObserver = RecordObserverFactory.shared.createRecordObserver(.Local)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleViewClicked(notification:)), name: Notification.Name.TitleViewClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCommandButtonClicked(notification:)), name: Notification.Name.CommandButtonClicked, object: nil)
        
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RecordsViewDidAppear, object: nil, userInfo: userInfoDict)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        self.recordObserver.reload()
        self.records = []
        self.observeRecord()
    }
    
    
    // MARK: - UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HHmm", options: 0, locale: Locale.current)
        label1.text = formatter.string(from: record.dateTime!)

        let imageView = cell.contentView.viewWithTag(2) as! UIImageView
        imageView.contentMode = .scaleAspectFit
        let cellImage = UIImage(named: Command.image(id: Int(record.commandId!)!)!)
        imageView.image = cellImage

        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        label2.text = Command.name(id: Int(record.commandId!)!)

        let label3 = cell.contentView.viewWithTag(4) as! UILabel
        label3.text = record.value1

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        let storyboard: UIStoryboard = self.storyboard!
        let editMilkViewController = storyboard.instantiateViewController(withIdentifier: "EditMilkViewController") as! EditMilkViewController
        editMilkViewController.id = record.id!
        self.present(editMilkViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }


    // MARK: - Event
    @objc func onTitleViewClicked(notification: Notification) -> Void {
        self.recordObserver.reload()
        self.records = []
        self.observeRecord()
    }
    
    @objc func onCommandButtonClicked(notification: Notification) -> Void {
        self.recordObserver.reload()
        self.records = []
        self.observeRecord()
    }

    
    // MARK: - Utility
    func modify(_ newRecord: RecordModel) {
        for record in self.records {
            if (record.id == newRecord.id) {
                record.babyId = newRecord.babyId
                record.commandId = newRecord.commandId
                record.dateTime = newRecord.dateTime
                record.userId = newRecord.userId
                record.value1 = newRecord.value1
                record.value2 = newRecord.value2
                record.value3 = newRecord.value3
                record.value4 = newRecord.value4
                record.value5 = newRecord.value5
            }
        }
    }
    
    func delete(_ target: RecordModel) {
        var index = 0
        let tempRecords = records
        for record in tempRecords {
            if (record.id == target.id) {
                records.remove(at: index)
            }
            index = index + 1
        }
    }
    
    func observeRecord() {
        guard let date = self.date else { return }
        let realm = try! Realm()
        let babyId = UserDefaults.standard.object(forKey: UserDefaultsKey.BabyId.rawValue) as? String ?? realm.objects(Baby.self).first?.id
        guard let unwrappedBabyId = babyId else { return }
        
        let from = Calendar.current.startOfDay(for: date)
        let to = from + 60 * 60 * 24 // 後半の60 * 60 * 24は登録したばかりのレコードを表示するため。
        
        self.recordObserver.observe(babyId: unwrappedBabyId, from: from, to: to, with: { (recordAndChanges) in
            for recordAndChange in recordAndChanges {
                let record = recordAndChange.0
                let change = recordAndChange.1

                guard record.babyId == unwrappedBabyId && from <= record.dateTime! && record.dateTime! <= to else { continue }
                switch change {
                case .Init:
                    self.records.append(record)
                case .Insert:
                    self.records.append(record)
                case .Modify:
                    self.modify(record)
                case .Delete:
                    self.delete(record)
                }
            }
            self.tableView.reloadData()
        })
    }
}

extension Notification.Name {
    static let RecordsViewDidAppear = Notification.Name("RecordsViewDidAppear")
}
