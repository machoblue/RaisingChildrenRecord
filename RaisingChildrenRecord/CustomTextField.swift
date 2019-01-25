//
//  CustomTextField.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/22.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }

}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        self.resignFirstResponder()
        
        return true
    }
    
}
