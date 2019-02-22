//
//  CreateFamilyViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/08.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import Firebase

import Shared

class CreateFamilyViewController: InterstitialAdBaseViewController {
    typealias SectionModel = (title: String, rowCount: Int, cellReuseIdentifier: String)
    let sections: [SectionModel] = [
        SectionModel("家族ID(半角英数字の任意の文字列を指定できます)", 1, "TextFieldCell")
    ]
    
    weak var familyId: UITextField!

    var ref: DatabaseReference!
    var babyDaoLocal: BabyDao!
    var recordDaoLocal: RecordDao!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.ref = Database.database().reference()
        babyDaoLocal = BabyDaoFactory.shared.createBabyDao(.Local)
        recordDaoLocal = RecordDaoFactory.shared.createRecordDao(.Local)
        
        navigationItem.title = "家族を新規作成する"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "作成", style: .plain, target: self, action: #selector(onCreateButtonClicked(_:)))
        
        AdUtils.shared.loadAndAddAdView(self)
    }
    

    @objc func onCreateButtonClicked(_ sender: Any) {
        guard let familyId = self.familyId.text else {
            self.showAlert(title: "エラー", message: "家族IDを入力してください。")
            return
        }
        
        guard familyId != "" else {
            self.showAlert(title: "エラー", message: "家族IDを入力してください。")
            return
        }
        
        guard familyId.isValidFamilyId() else {
            self.showAlert(title: "エラー", message: "家族IDは半角英数字で入力してください。")
            return
        }
        
        let userId = Auth.auth().currentUser?.uid
//        let userName = Auth.auth().currentUser?.displayName
//        ref.child("users").child(userId!).setValue(["name": userName]) // user who uses email to signup doesn't have displayName
        
        self.ref.child("families").child(familyId).setValue(["dummy": true]) { // 一旦家族を作成する
            (error: Error?, ref: DatabaseReference) in
            if let error = error {
                self.showAlert(title: "エラー", message: "入力した家族IDはすでにつかわれています。：" + error.localizedDescription)

            } else {
                self.ref.child("users").child(userId!).child("families").setValue([familyId: true]) { (error: Error?, ref: DatabaseReference) in
                    if let _ = error {
                    } else {
                        DispatchQueue.main.async {
                            UserDefaults.standard.register(defaults: [UserDefaults.Keys.FamilyId.rawValue: familyId])
                        }
                        
                        var recordsDict: [String:[String: Any]] = [:]

                        let babies = self.babyDaoLocal.findAll()
                        for baby in babies {
                            self.ref.child("families").child(familyId).child("babies").child(baby.id).setValue(baby.dictionary)
                            let records = self.recordDaoLocal.find(babyId: baby.id)
                            for record in records {
                                recordsDict[record.id] = record.dictionary
                            }
                        }
                        self.ref.child("families").child(familyId).child("records").setValue(recordsDict)
                        FirebaseUtils.shared.observeRemote()
                        
                        self.showInterstitial {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }


    }
    
    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        self.showInterstitial {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil) // display alert
    }
    
}

extension CreateFamilyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionModel.cellReuseIdentifier, for: indexPath)
        if let cell = cell as? TextFieldTableViewCell {
            familyId = cell.textField
            familyId.layer.cornerRadius = 10
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

extension CreateFamilyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class TextFieldTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
}

extension String {
    func isValidFamilyId() -> Bool {
        let pattern = "^[0-9a-zA-Z]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.count))
        return matches.count > 0
    }
}
