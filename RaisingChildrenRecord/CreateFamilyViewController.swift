//
//  CreateFamilyViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/08.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift
import CustomRealmObject

import Firebase

class CreateFamilyViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var familyId: UITextField!
    
    var ref: DatabaseReference!
    
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
    
    @IBAction func onCreateButtonClicked(_ sender: Any) {
        guard let familyId = self.familyId.text else {
            self.showAlert(title: "エラー", message: "家族IDを入力してください。")
            return
        }
        
        guard familyId != "" else {
            self.showAlert(title: "エラー", message: "家族IDを入力してください。")
            return
        }
        
        let userId = Auth.auth().currentUser?.uid
        let userName = Auth.auth().currentUser?.displayName
        ref.child("users").child(userId!).setValue(["name": userName])
        
        self.ref.child("families").child(familyId).setValue(["dummy": true]) { // 一旦家族を作成する
            (error: Error?, ref: DatabaseReference) in
            if let error = error {
                self.showAlert(title: "エラー", message: "入力した家族IDはすでにつかわれています。：" + error.localizedDescription)

            } else {
                self.ref.child("users").child(userId!).child("families").setValue([familyId: true]) { (error: Error?, ref: DatabaseReference) in
                    if let _ = error {
                    } else {
                        UserDefaults.standard.register(defaults: [UserDefaultsKey.FamilyId.rawValue: familyId])
                        
                        let realm = try! Realm()
                        let babies = realm.objects(Baby.self)
                        for baby in babies {
                            let records = realm.objects(Record.self).filter("babyId == %@", baby.id)
                            self.ref.child("families").child(familyId).child("babies").child(baby.id).setValue(["name": baby.name, "born": baby.born.timeIntervalSince1970, "female": baby.female])
                            for record in records {
                                self.ref.child("families").child(familyId)
                                    .child("babies").child(baby.id)
                                    .child("records").child(record.id)
                                    .setValue([
                                        "commandId": record.commandId!,
                                        "dateTime": record.dateTime!.timeIntervalSince1970,
                                        "value1": record.value1 ?? "",
                                        "value2": record.value2 ?? "",
                                        "value3": record.value3 ?? "",
                                        "value4": record.value4 ?? "",
                                        "value5": record.value5 ?? ""]) {
                                            (error: Error?, ref: DatabaseReference) in
                                            if let error = error {
                                                self.showAlert(title: "エラー", message: "家族の新規作成に失敗しました。：" + error.localizedDescription)
                                                
                                                
                                            } else {
                                                print("Succeed Creating")
                                            }
                                }
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }


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
