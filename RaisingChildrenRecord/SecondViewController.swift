//
//  SecondViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import Firebase

import Shared

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableFooterView: UIView!
    
    var sections: [(header: String, cells: [(label1: String, label2: String)])]
        = [(header: "赤ちゃんを切り替える", cells: []),
           (header: "赤ちゃんを編集する", cells: []),
           (header: "データ共有", cells: [(label1: "家族を新規作成する", label2: ""),
                                        (label1: "家族に他のユーザーを招待する", label2: ""),
                                        (label1: "招待された家族に参加する", label2: ""),
                                        (label1: "共有した記録を全て削除する", label2: ""),
                                        (label1: "サインアウト", label2: "")])]
    var babies: Array<BabyModel> = []
    
    var ref: DatabaseReference!
    
    var babyObserver: BabyObserver?
    
    var interstitial: GADInterstitial!
    
    // MARK: - UIViewController LifeCycle Callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
        self.babyObserver = BabyObserverFactory.shared.createBabyObserver(.Local)
        
        self.babyObserver?.observe(with: {(babyAndChangeArray) -> Void in
            for babyAndChange in babyAndChangeArray {
                let baby = babyAndChange.0
                let change = babyAndChange.1
                switch change {
                case .Init:
                    print("*** SecondViewController.viewDidLoad.observe.Init ***")
                    self.babies.append(baby)
                case .Insert:
                    print("*** SecondViewController.viewDidLoad.observe.Insert ***")
                    self.babies.append(baby)
                case .Modify:
                    print("*** SecondViewController.viewDidLoad.observe.Modify ***")
                    self.modify(baby)
                case .Delete:
                    print("*** SecondViewController.viewDidLoad.observe.Delete***")
                    self.delete(baby)
                }
            }
            self.updateSections()
            self.tableView?.reloadData()
        })
        
        AdUtils.shared.loadAndAddAdView(self)
        
        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
        NotificationCenter.default.addObserver(self, selector: #selector(onShowInterstitialAd(notification:)), name: .ShowInterstitialAd, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        configureTableFooter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.ref.removeAllObservers() // TODO: Is it correct to remove all observers here?
    }
    
    
    
    
    // MARK: - UITableViewDateSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.text = sections[section].cells[row].label1
            let label2 = cell.viewWithTag(2) as! UILabel
            label2.text = sections[section].cells[row].label2
            cell.accessoryType = isSelected(babies[row].id) ? .checkmark : .none

        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.text = sections[section].cells[row].label1
            let label2 = cell.viewWithTag(2) as! UILabel
            label2.text = sections[section].cells[row].label2
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "ShareCell", for: indexPath)
            let label = cell.viewWithTag(1) as! UILabel
            label.text = sections[section].cells[row].label1

        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            if (!isSelected(babies[row].id)) {
                for row in 0..<sections[0].cells.count {
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
                    cell?.accessoryType = .none
                }
            
                let selectedCell = tableView.cellForRow(at: indexPath)!
                selectedCell.accessoryType = .checkmark
            
                select(babies[row].id)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case 1:
            switch row {
            case sections[1].cells.count - 1:
                // to AddBabyScreen
                let storyboard: UIStoryboard = self.storyboard!
                let editBabyViewController = storyboard.instantiateViewController(withIdentifier: "EditBabyViewController") as! EditBabyViewController
                editBabyViewController.baby = nil
                self.present(editBabyViewController, animated: true, completion: nil)
            
            default:
                // to EditBabyScreen
                let storyboard: UIStoryboard = self.storyboard!
                let editBabyViewController = storyboard.instantiateViewController(withIdentifier: "EditBabyViewController") as! EditBabyViewController
                editBabyViewController.baby = babies[row]
                self.present(editBabyViewController, animated: true, completion: nil)
            }
        
        case 2:
            switch row {
            case 0:
                createFamily()
            case 1:
                addFamily()
            case 2:
                joinFamily()
            case 3:
                deleteFamilyData()
            case 4:
                signOut()
            default:
                break
            }
            
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            }
        
        default:
            break
        }
    }
    
    
    // MARK: - Utility
    func isSelected(_ babyId: String) -> Bool {
        let currentBabyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String
        if let unwrappedCurrentBabyId = currentBabyId {
            return unwrappedCurrentBabyId == babyId
        } else {
            let firstBabyId = babies.first!.id
            select(firstBabyId)
            return firstBabyId == babyId
        }
    }
    
    func select(_ babyId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [UserDefaults.Keys.BabyId.rawValue: babyId])
    }
    
    func createFamily() {
        guard let _ = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        let userDefaultsFamilyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard userDefaultsFamilyId == nil || userDefaultsFamilyId! == "" else {
            UIUtils.shared.showAlert(title: "ご注意", message: "すでに家族に加わっているため、新しい家族を作成できません。", viewController: self)
            return // return when userDefaultsFamilyId is nil or ""
        }
        
        let storyboard: UIStoryboard = self.storyboard!
        let createFamilyViewController = storyboard.instantiateViewController(withIdentifier: "CreateFamilyViewController") as! CreateFamilyViewController
        self.present(createFamilyViewController, animated: true, completion: nil)
    }
    
    func addFamily() {
        guard let _ = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        guard let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String,
            !familyId.isEmpty else {
            UIUtils.shared.showAlert(title: "ご注意", message: "他のユーザーを家族に加える前に、新しく家族を作成してください。", viewController: self)
            return
        }
        
        // create onetime password
        let passcode = String(format: "%06d", arc4random_uniform(1000000))
        let expirationDate = Date() + 60 * 5 // 5 minutes

        // save onetime password and expiration date
        self.ref.child("families").child(familyId).child("passcode").setValue(["value": passcode, "expirationDate": expirationDate.timeIntervalSince1970])

        // display familyId and onetime password
        let storyboard: UIStoryboard = self.storyboard!
        let familyIdAndPasscodeViewController = storyboard.instantiateViewController(withIdentifier: "FamilyIdAndPasscodeViewController") as! FamilyIdAndPasscodeViewController
        familyIdAndPasscodeViewController.familyIdText = familyId
        familyIdAndPasscodeViewController.passcodeText = passcode
        self.present(familyIdAndPasscodeViewController, animated: true, completion: nil)
    }
    
    func joinFamily() {
        guard let _ = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        let userDefaultsFamilyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard userDefaultsFamilyId == nil || userDefaultsFamilyId == "" else {
            UIUtils.shared.showAlert(title: "ご注意", message: "すでに家族に加わっているため、他の家族には加われません。", viewController: self)
            return // return when userDefaultsFamilyId is nil or ""
        }
        
        let storyboard: UIStoryboard = self.storyboard!
        let joinFamilyViewController = storyboard.instantiateViewController(withIdentifier: "JoinFamilyViewController") as! JoinFamilyViewController
        self.present(joinFamilyViewController, animated: true, completion: nil)
    }
    
    func deleteFamilyData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        guard let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String,
            !familyId.isEmpty else {
            UIUtils.shared.showAlert(title: "ご注意", message: "どの家族にも加わっていないため、削除機能は利用できません。", viewController: self)
            return // return when userDefaultsFamilyId is nil or ""
        }
        
        let title = "記録を削除するときのご注意"
        let message = "一度削除すると元に戻せません。また、家族を抜けることになります。よろしいですか？"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            
            FirebaseUtils.shared.invalidateObservation()
            
            self.ref.child("families").child(familyId).child("records").observeSingleEvent(of: .value, with: { (snapshot) in
                guard let recordsDict = snapshot.value as? NSDictionary else { return }
                var keysToDelete: [String] = []
                for key in recordsDict.allKeys {
                    let recordDict = recordsDict.value(forKey: key as! String) as! NSDictionary
                    if (recordDict["userId"] as? String == userId) {
                        keysToDelete.append(key as! String)
                    }
                }

                var recordsToUpdate: [AnyHashable: Any] = [:]
                for keyToDelete in keysToDelete {
                    recordsToUpdate[keyToDelete] = NSNull()
                }
                
                self.ref.child("families").child(familyId).child("records").updateChildValues(recordsToUpdate, withCompletionBlock: {(error, snapshot) in
                    if let error = error {
                        print("データ削除に失敗しました。", error)
                    } else {
                        self.ref.child("users").child(userId).child("families").removeValue()
                    }
                })
            })

            UserDefaults.standard.register(defaults: [UserDefaults.Keys.FamilyId.rawValue: ""])
            UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.FamilyId.rawValue)
            self.configureTableFooter()
        })
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.IsSignInSkipped.rawValue: false])
            configureTableFooter()

        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func updateSections() {
        sections[0].cells = []
        sections[1].cells = []
        
        for baby in babies {
            let name = baby.name
            let yyyyMMdd = UIUtils.shared.formatToLongYYYYMMDD(baby.born)
            let born = "\(yyyyMMdd)生まれ"
            
            sections[0].cells.append((label1: name, label2: born))
            sections[1].cells.append((label1: name, label2: born))
        }
        
        sections[1].cells.append((label1: "赤ちゃん追加", label2: ""))
    }
    
    func modify(_ newBaby: BabyModel) {
        for baby in babies {
            if (baby.id == newBaby.id) {
                baby.name = newBaby.name
                baby.born = newBaby.born
                baby.female = newBaby.female
            }
        }
    }

    func delete(_ target: BabyModel) {
        var index = 0
        let tempBabies = babies
        for baby in tempBabies {
            if (baby.id == target.id) {
                babies.remove(at: index)
            }
            index = index + 1
        }
    }
    
    func configureTableFooter() {
        let userMailAddressLabel = tableFooterView.viewWithTag(1) as? UILabel
        let email = Auth.auth().currentUser?.email ?? ""
        userMailAddressLabel?.text = "サインイン中のユーザー: [\(email)]"
        
        let familyIdLabel = tableFooterView.viewWithTag(2) as? UILabel
        UserDefaults.standard.synchronize()
        let familyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String ?? ""
        familyIdLabel?.text = "あなたの家族の家族ID: [\(familyId)]"
        
        let appVersionLabel = tableFooterView.viewWithTag(3) as? UILabel
        let appVersion = "1.1"
        appVersionLabel?.text = "アプリのバージョン: [\(appVersion)]"
        
        tableView.tableFooterView = tableFooterView
    }
    
    @objc func onShowInterstitialAd(notification: Notification) -> Void  {
        AdUtils.shared.showInterstitial(interstitial, viewController: self)
    }
}

extension SecondViewController {
    
    func showAuthView() {
        let signInViewController = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.present(signInViewController, animated: true, completion: nil)
    }
    
    func showAuthAlert() {
        let title = "Googleログインが必要です。"
        let message = "この機能を利用するためにはGoogleログインが必要です。Googleログインしますか？"
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(cancelAction)
        let loginAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            self.showAuthView()
        })
        alert.addAction(loginAction)
        present(alert, animated: true, completion: nil) // display alert
    }
    
}

extension SecondViewController: GADInterstitialDelegate {
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        interstitial = AdUtils.shared.createAndLoadInterstitial(self)
    }
}
