//
//  LoginViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/08.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

//import FirebaseAuth

class LoginViewController: UIViewController {
    
//    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
    
    override func viewWillAppear(_ animated: Bool) { // 最初の_は何か
        super.viewDidDisappear(animated)
        print("ViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewWillDisappear/別の画面に遷移する直前")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
