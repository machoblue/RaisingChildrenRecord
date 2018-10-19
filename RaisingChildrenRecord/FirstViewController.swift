//
//  FirstViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import Intents

import CustomRealmObject

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var navigationItem2: UINavigationItem!
    
    var baby: BabyModel?
    var date: Date?
    var babies: [BabyModel]?
    
    var babyDao: BabyDao!
    var recordDao: RecordDao!
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        self.recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(onPageForward(notification:)), name: Notification.Name.PageForward, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onPageBackward(notification:)), name: Notification.Name.PageBackward, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRecordsViewDidAppear(notification:)), name: Notification.Name.RecordsViewDidAppear, object: nil)
    }
    
    
    // MARK: CollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Command.values.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CustomCollectionViewCell
        
        let cellImage = UIImage(named: Command.values[indexPath.row].image)
        cell.button.setBackgroundImage(cellImage, for: .normal)
        cell.button.setTitle(Command.values[indexPath.row].name, for: .normal)
        cell.button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        cell.button.addTarget(self, action: #selector(onClicked), for: .touchUpInside)
        cell.button.tag = Command.values[indexPath.row].id

        cell.label.text = Command.values[indexPath.row].name
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
        self.recordDao.insertOrUpdate(RecordModel(id: UUID().description, babyId: self.baby!.id, userId: "", commandId: sender.tag.description, dateTime: Date(),
                                                  value1: "", value2: "", value3: "", value4: "", value5: ""))

        if #available(iOS 12.0, *) {
            let intent = RecordCreateIntent()
            intent.baby = baby!.name
            intent.behavior = Command.behaviorName(id: sender.tag)
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.donate { error in
                guard error == nil else {
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            print("Fallback on Earlier versions")
        }
    }
    
    @objc func onTitleViewTapped(_ sender: UITapGestureRecognizer) {
        print("*** FirstViewController.onTitleViewTapped ***")
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
                userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: baby.id])
                return baby
            }
            
        } else {
            if let babyId = userDefaults.object(forKey: UserDefaultsKey.BabyId.rawValue) as? String {
                for b in babies! { // babies shouldn't be nil
                    if (b.id == babyId) {
                        return b
                    }
                }
            }
            
            let baby = babies!.first! // babies and first shouldn't be nil
            userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: baby.id])
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

extension Notification.Name {
    static let LeftBarButtonClicked = Notification.Name("LeftBarButtonClicked")
    static let RightBarButtonClicked = Notification.Name("RightBarButtonClicked")
    static let TitleViewClicked = Notification.Name("TitleViewClicked")
}

