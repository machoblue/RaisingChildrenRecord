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

class RecordsViewController: UIViewController {
    
    var date: Date?
    
    var records: [RecordModel] = []

    @IBOutlet weak var tableView: UITableView!
    
    var recordObserver: RecordObserver!
    var babyDao: BabyDao!
    
    var observationKey: RecordObserver.ObservationKey?

    // MARK: - ViewController lifecycle callback
    override func viewDidLoad() {
        print("*** RecordsViewController.viewDidLoad ***")
        super.viewDidLoad()
        
        self.recordObserver = RecordObserverFactory.shared.createRecordObserver(.Local)
        self.babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        
        // ページをめくった瞬間に表示するため、ここでもobserveする
        self.records = []
        self.observeRecord()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("*** RecordsViewController.viewDidAppear ***")
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleViewClicked(notification:)), name: Notification.Name.TitleViewClicked, object: nil)
        
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RecordsViewDidAppear, object: nil, userInfo: userInfoDict)
        
        // 設定画面の赤ちゃん切り替え後や、記録の編集後にtableviewに反映させるため、ここでobserveRecordする
        self.records = []
        self.observeRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("*** RecordsViewController.viewWillAppear ***")
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    // MARK: - Event
    @objc func onTitleViewClicked(notification: Notification) -> Void {
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
                record.note = newRecord.note
                record.number1 = newRecord.number1
                record.number2 = newRecord.number2
                record.decimal1 = newRecord.decimal1
                record.decimal2 = newRecord.decimal2
                record.text1 = newRecord.text1
                record.text2 = newRecord.text2
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
        print("*** RecordsViewController.observeRecord***")
        guard let date = self.date else { return }
        let babyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String ?? babyDao.findAll().first?.id
        guard let unwrappedBabyId = babyId else { return }
        
        let from = Calendar.current.startOfDay(for: date)
        let to = from + 60 * 60 * 24 // 後半の60 * 60 * 24は登録したばかりのレコードを表示するため。
        
        if let observationKey = observationKey {
            recordObserver.invalidate(observationKey)
        }
        
        observationKey = self.recordObserver.observe(babyId: unwrappedBabyId, from: from, to: to, with: { (recordAndChanges) in
            
            var needScroll = false
            
            for recordAndChange in recordAndChanges {
                let record = recordAndChange.0
                let change = recordAndChange.1

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
            
            if self.records.count > 0 {
                self.hideEmptyMessage()
            } else {
                self.showEmptyMessage()
            }
            
            self.records.sort(by: {$0.dateTime < $1.dateTime})
            
            self.tableView.reloadData()
            
            if needScroll {
                self.tableView.scrollToBottom()
            }
        })
    }
    
    deinit {
        guard let observationKey = observationKey else { return }
        recordObserver.invalidate(observationKey)
    }
    
    func showEmptyMessage() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 180, height: 21))
        label.textAlignment = .center
        label.text = " 記録がありません。下のボタンをタップして記録を追加してください。"
        label.textColor = UIColor.lightGray
        label.adjustsFontSizeToFitWidth = true
        tableView.tableFooterView = label
    }
    
    func hideEmptyMessage() {
        tableView.tableFooterView = nil
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

extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recordDetailViewController = storyboard?.instantiateViewController(withIdentifier: "RecordDetailViewController") as! RecordDetailViewController
        let record = records[tableView.indexPathForSelectedRow!.row]
        recordDetailViewController.configure(record: record)
        navigationController?.pushViewController(recordDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

extension RecordsViewController: UITableViewDataSource {
    // MARK: - UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = records[indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        label1.text = UIUtils.shared.formatToHHMM(record.dateTime)
        
        let imageView = cell.contentView.viewWithTag(2) as! UIImageView
        imageView.contentMode = .scaleAspectFit
        let cellImage = UIImage(named: Commands.command(from: record.commandId)!.image)
        imageView.image = cellImage
        
        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        label2.text = Commands.command(from: record.commandId)?.name
        
        let label3 = cell.contentView.viewWithTag(4) as! UILabel
        label3.text = record.label
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
