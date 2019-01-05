//
//  RecordsViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/09.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import Shared

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var date: Date?
    
    var records: [RecordModel] = []

    @IBOutlet weak var tableView: UITableView!
    
    var recordObserver: RecordObserver!
    var babyDao: BabyDao!

    // MARK: - ViewController lifecycle callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordObserver = RecordObserverFactory.shared.createRecordObserver(.Local)
        self.babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        
        // ページをめくった瞬間に表示するため、ここでもobserveする
        self.records = []
        self.observeRecord()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*** RecordViewController.viewDidAppear ***")
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleViewClicked(notification:)), name: Notification.Name.TitleViewClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCommandButtonClicked(notification:)), name: Notification.Name.CommandButtonClicked, object: nil)
        
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RecordsViewDidAppear, object: nil, userInfo: userInfoDict)
        
        // 設定画面の赤ちゃん切り替え後や、記録の編集後にtableviewに反映させるため、ここでobserveRecordする
        self.records = []
        self.observeRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("*** RecordViewController.viewWillAppear ***")
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("*** RecordViewController.viewWillDisappear ***")
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("*** RecordViewController.viewDidDisappear ***")
        super.viewWillDisappear(animated)
        
        // 1. 次のRecordsViewControllerのviewWillAppear
        // 2. 前のRecordsViewControllerのviewWillDisappear
        // 3. 前のRecordsViewControllerのviewDidDisappear  <-observe終了
        // 4. 次のRecordsViewControllerのviewDidAppear     <-observe開始
        self.recordObserver.invalidate()
        records = []
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
        label3.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        if (record.commandId == "1") {
            label3.text = record.value2 == nil || record.value2 == "" ? "" : record.value2! + "ml"
        } else if (record.commandId == "2") {
            label3.text = record.value2 == nil || record.value2 == "" ? "" : record.value2! + "分"
        } else if (record.commandId == "5") {
            label3.text = record.value2 == nil || record.value2 == "" ? "" : record.value2! + "℃"
        } else if (record.commandId == "6") {
            label3.text = record.value2 == nil || record.value2 == "" ? "" : Command.HardnessOption(rawValue: record.value2!)!.label
        } else {
            label3.text = record.value1
        }

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let recordDetailViewController = storyboard.instantiateViewController(withIdentifier: "RecordDetailViewController") as! RecordDetailViewController
        let record = records[indexPath.row]
        recordDetailViewController.configure(record: record)
        self.present(recordDetailViewController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }


    // MARK: - Event
    @objc func onTitleViewClicked(notification: Notification) -> Void {
        self.records = []
        self.observeRecord()
    }
    
    @objc func onCommandButtonClicked(notification: Notification) -> Void {
        print("*** RecordsViewController.onCommandButtonClicked ***")
//        self.records = []
//        self.observeRecord()
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
        print("*** RecordsViewController.delete *** records.count:", records.count)
    }
    
    func observeRecord() {
        print("*** RecordViewController.observeRecord ***")
        guard let date = self.date else { return }
        let babyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String ?? babyDao.findAll().first?.id
        guard let unwrappedBabyId = babyId else { return }
        
        let from = Calendar.current.startOfDay(for: date)
        let to = from + 60 * 60 * 24 // 後半の60 * 60 * 24は登録したばかりのレコードを表示するため。
        
        self.recordObserver.observe(babyId: unwrappedBabyId, from: from, to: to, with: { (recordAndChanges) in
            print("*** RecordViewController.observeRecord.recordObserver.observe *** recordAndChanges.count:", recordAndChanges.count)
            
            var needScroll = false
            
            for recordAndChange in recordAndChanges {
                let record = recordAndChange.0
                let change = recordAndChange.1
                print("*** RecordViewController.observeRecord.recordObserver.observe.for *** :", recordAndChange)

                switch change {
                case .Init:
                    self.records.append(record)
                case .Insert:
                    self.records.append(record)
                    needScroll = true
                case .Modify:
                    self.modify(record)
                case .Delete:
                    self.delete(record)
                }
            }
            self.tableView.reloadData()
            
            if needScroll {
                self.tableView.scrollToBottom()
            }
        })
    }
}

extension Notification.Name {
    static let RecordsViewDidAppear = Notification.Name("RecordsViewDidAppear")
}

extension UITableView {
    
    func scrollToBottom(){
        
        DispatchQueue.main.async {
            var row = self.numberOfRows(inSection:  self.numberOfSections - 1) - 1
            row = row >= 0 ? row : 0
            var section = self.numberOfSections - 1
            section = section >= 0 ? section : 0
            
            let indexPath = IndexPath(
                row: row,
                section: section)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
