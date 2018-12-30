//
//  JoinFamilyViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/06.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit
import Firebase

import Shared

class JoinFamilyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var familyId: UITextField!
    @IBOutlet weak var passcode: UITextField!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    var babyDaoLocal: BabyDao!
    var recordDaoLocal: RecordDao!

    // MARK: - UIViewController lifecycle callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicatorView)
        
        ref = Database.database().reference()
        babyDaoLocal = BabyDaoFactory.shared.createBabyDao(.Local)
        recordDaoLocal = RecordDaoFactory.shared.createRecordDao(.Local)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Mark: TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: Event
    @IBAction func onJoinButtonClicked(_ sender: Any) {
        let title = "家族に参加するときのご注意"
        let message = "家族に参加すると、これまでこの端末で保存したデータが消えます。よろしいですか？"
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(cancelAction)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            
            self.activityIndicatorView.startAnimating()
            
            // enable user to enter familyId and onetime password
            let familyId = self.familyId.text
            let passcode = self.passcode.text
            
            // try add his userId his family
            let userId = Auth.auth().currentUser?.uid
            let userName = Auth.auth().currentUser?.displayName
            self.ref.child("users").child(userId!).setValue(["name": userName!, "passcode": passcode])
            
            // join family
            self.ref.child("users").child(userId!).child("families").setValue([familyId: true]) {
                (error: Error?, ref: DatabaseReference) in
                if let error = error {
                    self.activityIndicatorView.stopAnimating()
                    self.showAlert(title: "エラー", message: "家族への参加に失敗しました。：" + error.localizedDescription)
                    
                } else {
                    print("Succeed Joining")
                    UserDefaults.standard.register(defaults: [UserDefaults.Keys.FamilyId.rawValue: familyId ?? ""])
                    
                    // remove all local data
                    let babiesRef = self.ref.child("families").child(familyId!).child("babies")
                    babiesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let babiesDict = snapshot.value as? NSDictionary else { return }
                        var newBabies: [BabyModel] = []
                        for key in babiesDict.allKeys {
                            let babyDict = babiesDict.value(forKey: key as! String) as! NSDictionary
                            guard let newBaby = self.baby(key: key as! String, dict: babyDict) else { return }
//                            self.babyDaoLocal?.insertOrUpdate(newBaby)
                            newBabies.append(newBaby)
                        }

                        self.babyDaoLocal.deleteAll()
                        
                        for newBaby in newBabies {
                            self.babyDaoLocal.insertOrUpdate(newBaby)
                        }
                        
                        self.recordDaoLocal.deleteAll()
                        
                        FirebaseUtils.shared.observeRemote()
                        
                        self.activityIndicatorView.stopAnimating()
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
            
        })
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil) // display alert
    }
    
    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func showAlert(title: String, message: String) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil) // display alert
    }
    
    func baby(from snapshot: DataSnapshot) -> BabyModel? {
        guard let babyDict = snapshot.value as? NSDictionary else { return nil }
        return baby(key: snapshot.key, dict: babyDict)
    }
    
    func baby(key: String, dict babyDict: NSDictionary) -> BabyModel? {
        let id = key
        let name = babyDict["name"] as! String
        let born = Date(timeIntervalSince1970: babyDict["born"] as! Double)
        let female = babyDict["female"] as! Bool
        let newBaby = BabyModel(id: id, name: name, born: born, female: female)
        return newBaby
    }
}
