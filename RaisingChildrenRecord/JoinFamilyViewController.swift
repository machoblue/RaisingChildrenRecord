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
    
    var ref: DatabaseReference!
    
    // MARK: - UIViewController lifecycle callback
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference()
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
                self.showAlert(title: "エラー", message: "家族への参加に失敗しました。：" + error.localizedDescription)

            } else {
                print("Succeed Joining")
            }
        }
        UserDefaults.standard.register(defaults: [UserDefaultsKey.FamilyId.rawValue: familyId ?? ""])
        dismiss(animated: true, completion: nil)
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
}
