//
//  SignInViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/10.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

import Firebase

class SignInViewController: UIViewController {
    var onSignedIn: ((Bool) -> Void)?
    var onSkipped: ((Bool) -> Void)?
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true

        signInButton.layer.cornerRadius = 5
        
        registerButton.backgroundColor = .clear
        registerButton.layer.cornerRadius = 5
        registerButton.layer.borderWidth = 1
        registerButton.layer.borderColor = UIColor.gray.cgColor
        
        activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicatorView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let signUpViewController = segue.destination as? SignUpViewController else { return }
        signUpViewController.onSignedUp = { result in
            if result {
                self.dismiss(animated: true, completion: nil)
                if let onSignedIn = self.onSignedIn {
                    onSignedIn(true)
                }
                UserDefaults.standard.register(defaults: [UserDefaults.Keys.IsSignInSkipped.rawValue: false])
            }
        }
    }
    
    @IBAction func onSignInButtonClicked(_ sender: Any) {
        guard let mail = mail.text, !mail.isEmpty else {
            UIUtils.shared.showAlert(title: "サインインエラー", message: "メールアドレスを入力してください。", viewController: self)
            return
        }
        
        guard let password = password.text, !password.isEmpty else {
            UIUtils.shared.showAlert(title: "サインインエラー", message: "パスワードを入力してください。", viewController: self)
            return
        }
        
        self.activityIndicatorView.startAnimating()
        
        Auth.auth().signIn(withEmail: mail, password: password) { (user, error) in
            self.activityIndicatorView.stopAnimating()
            
            if let error = error {
                UIUtils.shared.showAlert(title: "サインインエラー", message: error.localizedDescription, viewController: self)
                print(error.localizedDescription)
                
            } else {
                self.dismiss(animated: true, completion: nil)
                if let onSignedIn = self.onSignedIn {
                    onSignedIn(true)
                }
                UserDefaults.standard.register(defaults: [UserDefaults.Keys.IsSignInSkipped.rawValue: false])
            }
        }
    }
    
    @IBAction func onSkipButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        if let onSkipped = self.onSkipped {
            onSkipped(true)
        }
        
        UserDefaults.standard.register(defaults: [UserDefaults.Keys.IsSignInSkipped.rawValue: true])
    }
    
}
