//
//  UIUtils.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/01/11.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import Foundation

import UIKit

class UIUtils {
    public static let shared = UIUtils()
    private init() {
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil) // display alert
    }
}
