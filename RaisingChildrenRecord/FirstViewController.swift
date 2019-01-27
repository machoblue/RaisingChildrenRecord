//
//  FirstViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit
import os.log

import RealmSwift

import Intents

import Shared

class FirstViewController: UIViewController {

    @IBOutlet weak var navigationItem2: UINavigationItem!
    
    var baby: BabyModel?
    var date: Date?
    var babies: [BabyModel]?
    
    var babyDao: BabyDao!
    var recordDao: RecordDao!
    var recordDaoRemote: RecordDao!
    
    private var notificationToken: NSObjectProtocol?
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        self.recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
        self.recordDaoRemote = RecordDaoFactory.shared.createRecordDao(.Remote)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.baby = nil // 初期化
        
        self.babies = babyDao.findAll()
        self.baby = nextBaby()
        self.date = Date()
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame, baby: self.baby, date: self.date)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTitleViewTapped(_:)))
        self.navigationItem2.titleView?.addGestureRecognizer(gesture)
        self.navigationItem2.titleView?.isUserInteractionEnabled = true
        
        // why observe at viewDidAppear
        NotificationCenter.default.addObserver(self, selector: #selector(onPageForward(notification:)), name: Notification.Name.PageForward, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPageBackward(notification:)), name: Notification.Name.PageBackward, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordsViewDidAppear(notification:)), name: Notification.Name.RecordsViewDidAppear, object: nil)
    }
    
    @objc func onPageForward(notification: Notification) -> Void {
        self.date =  (notification.userInfo?["date"] as! Date)
        self.reloadTitleView(self.navigationItem2, baby: self.baby!, data: self.date!)
    }
    
    @objc func onPageBackward(notification: Notification) -> Void {
        self.date = (notification.userInfo!["date"] as! Date)
        self.reloadTitleView(self.navigationItem2, baby: self.baby!, data: self.date!)
    }
    
    @objc func onRecordsViewDidAppear(notification: Notification) -> Void {
        self.date = (notification.userInfo!["date"] as! Date)
        self.reloadTitleView(self.navigationItem2, baby: self.baby!, data: self.date!)
    }
    
    // MARK: - Event
    @objc func onClicked(sender: UIButton!) {
        let displayDate = self.date!
        let now = Date()
        let calendar = Calendar.current
        let ymd = calendar.dateComponents([.year, .month, .day], from: displayDate)
        let hms = calendar.dateComponents([.hour, .minute, .second], from: now)
        let date = calendar.date(from: DateComponents(year: ymd.year, month: ymd.month, day: ymd.day, hour: hms.hour, minute: hms.minute, second: hms.second))
        
        let record = RecordModel(id: UUID().description, babyId: self.baby!.id, userId: "", commandId: sender.tag, dateTime: date!, note: "", value2: "", value3: "", value4: "", value5: "")
        self.recordDao.insertOrUpdate(record)
        self.recordDaoRemote.insertOrUpdate(record)

        if #available(iOS 12.0, *) {
            let interaction = INInteraction(intent: record.intent, response: nil)
            interaction.donate { error in
                guard error == nil else {
                    os_log("Could not donate interaction: %@", log: OSLog.default, type: .error, error.debugDescription)
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            os_log("Fallback on Earlier versions", log: OSLog.default, type: .debug)
        }
    }
    
    @objc func onTitleViewTapped(_ sender: UITapGestureRecognizer) {
        self.baby = nextBaby()
        
        self.reloadTitleView(self.navigationItem2, baby: self.baby!, data: self.date!)

        let userInfoDict = ["babyId": self.baby!.id]
        NotificationCenter.default.post(name: .TitleViewClicked, object: nil, userInfo: userInfoDict)
    }
    
    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        self.date = self.date! - (60 * 60 * 24)
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .LeftBarButtonClicked, object: nil, userInfo: userInfoDict)
    }
    
    @IBAction func onRightBarButtonClicked(_ sender: Any) {
        self.date = self.date! + (60 * 60 * 24)
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RightBarButtonClicked, object: nil, userInfo: userInfoDict)
    }
    
    
    // MARK: - Utility
    func nextBaby() -> BabyModel {
        let userDefaults = UserDefaults.standard
        if let unwrappedBaby = self.baby {
            if babies!.count < 2 { // babies shouldn't be nil
                return unwrappedBaby
                
            } else {
                let index = self.index(of: unwrappedBaby)
                let baby = babies![(index + 1) % babies!.count] // babies shouldn't be nil
                userDefaults.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
                return baby
            }
            
        } else {
            if let babyId = userDefaults.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String {
                for b in babies! { // babies shouldn't be nil
                    if (b.id == babyId) {
                        return b
                    }
                }
            }
            
            let baby = babies!.first! // babies and first shouldn't be nil
            userDefaults.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
            return baby
        }
    }
    
    func index(of baby: BabyModel) -> Int {
        var index = 0
        for b in self.babies! {
            if baby.id == b.id {
                return index
            }
            index = index + 1
        }
        return -1
    }
    
    func reloadTitleView(_ navigationItem: UINavigationItem, baby: BabyModel, data: Date) {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        navigationItem.titleView = UICustomTitleView(frame: frame, baby: baby, date: date)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTitleViewTapped(_:)))
        navigationItem.titleView?.addGestureRecognizer(gesture)
    }
}

extension FirstViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Commands.values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
        
        let cellImage = UIImage(named: Commands.values[indexPath.row].image)
        cell.button.setBackgroundImage(cellImage, for: .normal)
        cell.button.setTitle("", for: .normal)
        cell.button.addTarget(self, action: #selector(onClicked), for: .touchUpInside)
        cell.button.tag = Commands.values[indexPath.row].id.rawValue
        
        cell.label.text = Commands.values[indexPath.row].name
        cell.label.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension FirstViewController: UICollectionViewDelegate {
}

extension Notification.Name {
    static let LeftBarButtonClicked = Notification.Name("LeftBarButtonClicked")
    static let RightBarButtonClicked = Notification.Name("RightBarButtonClicked")
    static let TitleViewClicked = Notification.Name("TitleViewClicked")
}
