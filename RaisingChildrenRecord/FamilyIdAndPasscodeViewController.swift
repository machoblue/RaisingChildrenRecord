//
//  FamilyIdAndPasscodeViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/05.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class FamilyIdAndPasscodeViewController: UIViewController {

    @IBOutlet weak var familyId: UILabel!
    @IBOutlet weak var passcode: UILabel!
    
    var familyIdText: String!
    var passcodeText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        familyId.text = familyIdText
        passcode.text = passcodeText

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
