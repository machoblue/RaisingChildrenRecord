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
        
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDoneButtonClicked))
        let toolbarItems = [spacer, doneButton]
        
        toolbar.setItems(toolbarItems, animated: true)
        
        inputAccessoryView = toolbar
    }
    
    @objc func onDoneButtonClicked(textView: UITextView) {
        self.resignFirstResponder()
    }

}

extension CustomTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        self.resignFirstResponder()
        
        return true
    }
    
}
