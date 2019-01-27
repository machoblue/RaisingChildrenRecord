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
    
    let longYYYYMMDDFormat = DateFormatter()
    let mediumYYYYMMDDFormat = DateFormatter()
    let hhmmFormat = DateFormatter()
    let YYYYMMDDHHmmFormat = DateFormatter()
    
    private init() {
        longYYYYMMDDFormat.locale = Locale(identifier: "ja_JP")
        longYYYYMMDDFormat.dateStyle = .long
        longYYYYMMDDFormat.timeStyle = .none
        
        mediumYYYYMMDDFormat.locale = Locale(identifier: "ja_JP")
        mediumYYYYMMDDFormat.dateStyle = .medium
        mediumYYYYMMDDFormat.timeStyle = .none
        
        hhmmFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "HHmm", options: 0, locale: Locale.current)
        
        YYYYMMDDHHmmFormat.locale = Locale(identifier: "ja_JP")
        YYYYMMDDHHmmFormat.dateStyle = .medium
        YYYYMMDDHHmmFormat.timeStyle = .short
    }
    
    func showAlert(title: String, message: String, viewController: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction!) -> Void in
            // do nothing
        })
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil) // display alert
    }
    
    func formatToLongYYYYMMDD(_ date: Date) -> String {
        return longYYYYMMDDFormat.string(from: date)
    }
    
    func formatToMediumYYYYMMDD(_ date: Date) -> String {
        return mediumYYYYMMDDFormat.string(from: date)
    }
    
    func formatToHHMM(_ date: Date) -> String {
        return hhmmFormat.string(from: date)
    }
    
    func formatToYYYYMMDDHHmm(_ date: Date) -> String {
        return YYYYMMDDHHmmFormat.string(from: date)
    }
}
