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
    
    var baby: Baby?
    var date: Date?
    var babies: Array<Baby>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.baby = nil // 初期化
        
        self.babies = findAllBabies()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // ### CollectionViewDelegate from ###
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
    // ### CollectionViewDelegate to ###
    
    // ### Notification from ###
    @objc func onPageForward(notification: Notification) -> Void {
        print("*** onPageForward ***")
//        self.date = self.date! + (60 * 60 * 24) // date should not be nil
        self.date = notification.userInfo!["date"] as! Date
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame, baby: self.baby, date: self.date)
    }
    
    @objc func onPageBackward(notification: Notification) -> Void {
        print("*** onPageBackward***")
//        self.date = self.date! - (60 * 60 * 24) // date should not be nil
        self.date = notification.userInfo!["date"] as! Date
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame, baby: self.baby, date: self.date)
    }
    
    @objc func onRecordsViewDidAppear(notification: Notification) -> Void {
        print("*** onRecordsViewdidAppear ***")
        self.date = notification.userInfo!["date"] as! Date
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame, baby: self.baby, date: self.date)
    }
    // ### Notification to ###

    @objc func onClicked(sender: UIButton!) {
        print("Button Clicked:", sender.tag)
        let realm = try! Realm()
        try! realm.write {
            let record = Record()
            record.babyId = self.baby!.id
            record.commandId = sender.tag.description
            record.dateTime = Date()
            realm.add(record)
        }
        
        if #available(iOS 12.0, *) {
            print("#######################")
            let intent = RecordCreateIntent()
            intent.baby = baby!.name
            intent.behavior = Command.behaviorName(id: sender.tag)
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.donate { error in
                guard error == nil else {
                    print("Problems donating your Intent")
                    return
                }
                print("Intent donated")
            }
        } else {
            // Fallback on earlier versions
            print("&&&&&&&&&&&&&")
        }
    }
    
    @objc func onTitleViewTapped(_ sender: UITapGestureRecognizer) {
        self.baby = nextBaby()
        
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 75)
        self.navigationItem2.titleView = UICustomTitleView(frame: frame, baby: self.baby, date: self.date)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTitleViewTapped(_:)))
        self.navigationItem2.titleView?.addGestureRecognizer(gesture)
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
    
    
    func nextBaby() -> Baby {
        let userDefaults = UserDefaults.standard
        if let unwrappedBaby = self.baby {
            if babies!.count < 2 { // babies shouldn't be nil
                return unwrappedBaby
                
            } else {
                let index = babies!.index(of: unwrappedBaby)! // unwrappedBaby should exist in babies
                let baby = babies![(index + 1) % babies!.count] // babies shouldn't be nil
                userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: baby.id])
                return baby
            }
            
        } else {
            let babyId = userDefaults.object(forKey: UserDefaultsKey.BabyId.rawValue) as? String
            if let unwrappedBabyId = babyId {
                var baby: Baby?
                for b in babies! { // babies shouldn't be nil
                    if (b.id == unwrappedBabyId) {
                        baby = b
                    }
                }
                
                if (baby == nil) {
                    userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: babies!.first!.id])
                    return babies!.first!
                    
                } else {
                    return baby!
                }

            } else {
                let baby = babies!.first! // babies and first shouldn't be nil
                userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: baby.id])
                return baby
            }
        }
    }
    
    func findAllBabies() -> Array<Baby> {
        let realm = try! Realm()
        let results: Results<Baby> = realm.objects(Baby.self)
        var babies: Array<Baby> = []
        for result in results {
            babies.append(result)
        }
        return babies
    }
    
}

extension Notification.Name {
    static let LeftBarButtonClicked = Notification.Name("LeftBarButtonClicked")
    static let RightBarButtonClicked = Notification.Name("RightBarButtonClicked")
}

