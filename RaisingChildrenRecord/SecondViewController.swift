//
//  SecondViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit
import os.log

import RealmSwift

import Firebase

import Shared

class SecondViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableFooterView: UIView!
    
    typealias SectionModel = (type: SectionType, title: String, rowCount: Int, cellReuseIdentifier: String)
    var sections: [SectionModel] = [
        SectionModel(.BabyOption, "赤ちゃんを切り替える", 0, "Cell"),
        SectionModel(.EditBabyButton, "赤ちゃんを編集する", 0, "Cell2"),
        SectionModel(.DataShareButton, "データを共有する", 5, "ShareCell")
    ]
    
    enum SectionType: String {
        case BabyOption
        case EditBabyButton
        case DataShareButton
    }
    
    typealias CellModel = (label: String, action: Selector)
    var cells: [CellModel] = [
        CellModel("家族を新規作成する", action: #selector(createFamily)),
        CellModel("家族に他のユーザーを招待する", action: #selector(addFamily)),
        CellModel("招待された家族に参加する", action: #selector(joinFamily)),
        CellModel("共有した記録を全て削除する", action: #selector(deleteFamilyData)),
        CellModel("サインアウト", action: #selector(signOut)),
    ]
    
    var babies: Array<BabyModel> = []
    
    var ref: DatabaseReference!
    
    var babyObserver: BabyObserver?
    
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
                    self.babies.append(baby)
                case .Insert:
                    self.babies.append(baby)
                case .Modify:
                    self.modify(baby)
                case .Delete:
                    self.delete(baby)
                }
            }
            self.updateSections()
            self.tableView?.reloadData()
        })
        
        AdUtils.shared.loadAndAddAdView(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        configureTableFooter()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.ref.removeAllObservers() // TODO: Is it correct to remove all observers here?
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
    
    @objc func createFamily() {
        guard let _ = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        let userDefaultsFamilyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard userDefaultsFamilyId == nil || userDefaultsFamilyId! == "" else {
            UIUtils.shared.showAlert(title: "ご注意", message: "すでに家族に加わっているため、新しい家族を作成できません。", viewController: self)
            return // return when userDefaultsFamilyId is nil or ""
        }
        
        performSegue(withIdentifier: "Create Family", sender: nil)
    }
    
    @objc func addFamily() {
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
        let parameterDict = ["familyId": familyId, "passcode": passcode]
        performSegue(withIdentifier: "Show FamilyId And Passcode", sender: parameterDict)
    }
    
    @objc func joinFamily() {
        guard let _ = Auth.auth().currentUser?.uid else {
            showAuthAlert()
            return
        }
        
        let userDefaultsFamilyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.FamilyId.rawValue) as? String
        guard userDefaultsFamilyId == nil || userDefaultsFamilyId == "" else {
            UIUtils.shared.showAlert(title: "ご注意", message: "すでに家族に加わっているため、他の家族には加われません。", viewController: self)
            return // return when userDefaultsFamilyId is nil or ""
        }
        
        performSegue(withIdentifier: "Join Family", sender: nil)
    }
    
    @objc func deleteFamilyData() {
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
                        os_log("Could not delete all records: %@", log: OSLog.default, type: .error, error.localizedDescription)
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
    
    @objc func signOut() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.IsSignInSkipped.rawValue: false])
            configureTableFooter()

        } catch let signOutError as NSError {
            os_log("Error signing out: %@", log: OSLog.default, type: .error, signOutError)
        }
    }
    
    func updateSections() {
        sections = [
            SectionModel(.BabyOption, "赤ちゃんを切り替える", babies.count, "Cell"),
            SectionModel(.EditBabyButton, "赤ちゃんを編集する", babies.count + 1, "Cell2"),
            SectionModel(.DataShareButton, "", 5, "ShareCell")
        ]
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
        let appVersion = "1.0.3"
        appVersionLabel?.text = "アプリのバージョン: [\(appVersion)]"
        
        tableView.tableFooterView = tableFooterView
    }
    
    @IBAction func onUnWind(segue: UIStoryboardSegue) {
        // do nothing
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

extension SecondViewController: UITableViewDataSource {
    // MARK: - UITableViewDateSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionModel.cellReuseIdentifier)!
        configure(cell, with: sectionModel, indexPath: indexPath)
        return cell
    }
    
    func configure(_ cell: UITableViewCell, with sectionModel: SectionModel, indexPath: IndexPath) {
        switch sectionModel.type {
        case .BabyOption:
            let baby = babies[indexPath.row]
            
            let name = baby.name
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.text = name
            
            let label2 = cell.viewWithTag(2) as! UILabel
            label2.text = "\(UIUtils.shared.formatToLongYYYYMMDD(baby.born))生まれ"
            
            cell.accessoryType = isSelected(babies[indexPath.row].id) ? .checkmark : .none
            
        case .EditBabyButton:
            if indexPath.row < babies.count {
                let baby = babies[indexPath.row]
                
                let name = baby.name
                let label1 = cell.viewWithTag(1) as! UILabel
                label1.text = name
                
                let label2 = cell.viewWithTag(2) as! UILabel
                label2.text = "\(UIUtils.shared.formatToLongYYYYMMDD(baby.born))生まれ"
                
            } else {
                let label1 = cell.viewWithTag(1) as! UILabel
                label1.text = "赤ちゃん追加"
                let label2 = cell.viewWithTag(2) as! UILabel
                label2.text = ""
            }
            
        case .DataShareButton:
            let cellModel = cells[indexPath.row]
            let label = cell.viewWithTag(1) as! UILabel
            label.text = cellModel.label
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
}

extension SecondViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        let sectionModel = sections[section]
        
        switch sectionModel.type {
        case .BabyOption:
            if (!isSelected(babies[row].id)) {
                for row in 0..<sections[0].rowCount {
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))
                    cell?.accessoryType = .none
                }
                
                let selectedCell = tableView.cellForRow(at: indexPath)!
                selectedCell.accessoryType = .checkmark
                
                select(babies[row].id)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case .EditBabyButton:
            performSegue(withIdentifier: "Show Baby Detail", sender: nil)
            
        case .DataShareButton:
            let cellModel = cells[indexPath.row]
            perform(cellModel.action)
            
            if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editBaby = segue.destination as? EditBabyViewController {
            let row = tableView.indexPathForSelectedRow!.row
            editBaby.baby = row >= babies.count ? nil : babies[row]
            
        } else if let familyIdAndPasscode = segue.destination as? FamilyIdAndPasscodeViewController {
            let parameterDict = sender as! [String: String]
            familyIdAndPasscode.familyIdText = parameterDict["familyId"]
            familyIdAndPasscode.passcodeText = parameterDict["passcode"]
        }
    }
}
