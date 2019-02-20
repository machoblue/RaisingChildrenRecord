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
    let YYYYMMFormat = DateFormatter()
    let MMFormat = DateFormatter()
    let dFormat = DateFormatter()
    let eeeeeFormat = DateFormatter()
    
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
        
        YYYYMMFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMM", options: 0, locale: Locale.current)
        // yMMM: yyyy年M月
        
        MMFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMM", options: 0, locale: Locale.current)
        
        dFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "d", options: 0, locale: Locale.current)
        
        eeeeeFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEE", options: 0, locale: Locale.current)
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
    
    func formatToYYYYMM(_ date: Date) -> String {
        return YYYYMMFormat.string(from: date)
    }
    
    func formatToMM(_ date: Date) -> String {
        return MMFormat.string(from: date)
    }
    
    func formatToMMOrYYYYMM(_ date: Date) -> String {
        let year = Calendar.current.component(.year, from: date)
        let currentYear = Calendar.current.component(.year, from: Date())
        if year == currentYear {
            return formatToMM(date)
        } else {
            return formatToYYYYMM(date)
        }
    }
    
    func formatToD(_ date: Date) -> String {
        return dFormat.string(from: date)
    }
    
    func formatToEEEEE(_ date: Date) -> String {
        return eeeeeFormat.string(from: date)
    }
    
    func resolveAge(born: Date, now: Date) -> String? {
        let f = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ja")
        f.calendar = calendar
        f.unitsStyle = .full
        f.allowedUnits = [.year, .month]
        
        let timeInterval = now.timeIntervalSince(born)
        
        var formatted = f.string(from: timeInterval)
        
        if let range = formatted?.range(of: "年") {
            formatted?.replaceSubrange(range, with: "歳")
        }
        
        return "(\(formatted!))"
    }
    
    func getFirstDateOfMonthCalendar(date: Date) -> Date {
        let yearAndMonth = Calendar.current.dateComponents([.year, .month], from: date)
        let firstDateOfThisMonth = Calendar.current.date(from: yearAndMonth)!
        let weekdayOfFirstDate = Calendar.current.component(.weekday, from: firstDateOfThisMonth)
        let firstDateOfMonthCalendar = Date(timeInterval: TimeInterval((-weekdayOfFirstDate + 1) * 60 * 60 * 24), since: firstDateOfThisMonth)
        return firstDateOfMonthCalendar
    }
}
