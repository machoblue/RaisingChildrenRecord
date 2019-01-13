//
//  SignUpViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/10.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

import Firebase

class SignUpViewController: UIViewController {
    var onSignedUp: ((Bool) -> Void)?

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var password2: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true
        password2.isSecureTextEntry = true

        registerButton.layer.cornerRadius = 5
        
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicatorView)
    }
    
    @IBAction func onRegisterButtonClicked(_ sender: Any) {
        guard let mail = mail.text, !mail.isEmpty else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "メールアドレスを入力してください。", viewController: self)
            return
        }
        
        guard let password = password.text, !password.isEmpty else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "パスワードを入力してください。", viewController: self)
            return
        }
        
        guard let password2 = password2.text, !password2.isEmpty else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "パスワードを入力してください。", viewController: self)
            return
        }
        
        guard password == password2 else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "パスワードと確認用パスワードを一致させてください。", viewController: self)
            return
        }
        
        guard isValidEmail(mail) else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "メールアドレスの形式が不正です。正しいメールアドレスを入力してください。", viewController: self)
            return
        }
        
        guard isValidPassword(password) else {
            UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: "パスワードの形式が不正です。パスワードは半角英小文字、半角英大文字、半角数字のそれぞれを少なくとも1文字含む8文字以上の文字列としてください。", viewController: self)
            return
        }
        
        self.activityIndicatorView.startAnimating()
        
        Auth.auth().createUser(withEmail: mail, password: password) { (authResult, error) in
            
            self.activityIndicatorView.stopAnimating()
            
            if let error = error {
                UIUtils.shared.showAlert(title: "ユーザー登録エラー", message: error.localizedDescription, viewController: self)
                
            } else {
                self.dismiss(animated: true, completion: nil)
                if let onSignedUp = self.onSignedUp {
                    onSignedUp(true)
                }
            }
        }
    }
    
    @IBAction func onCancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    func isValidEmail(_ string: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }
    
    func isValidPassword(_ string: String) -> Bool {
        let passwordRegEx = "^(?=.*?[a-z])(?=.*?[A-Z])(?=.*?[0-9])[!-~]{8,100}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        let result = passwordTest.evaluate(with: string)
        return result
    }
}


extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        
        return true
    }
}
