//
//  PageViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/24.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.date = Date()
        self.setViewControllers([getViewController(date)], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
        
        // disable transit on tap
        for recognizer in self.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLeftBarButtonClicked(notification:)), name: Notification.Name.LeftBarButtonClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onRightBarButtonClicked(notification:)), name: Notification.Name.RightBarButtonClicked, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getViewController(_ date: Date) -> RecordsViewController {
        let recordsViewController =  storyboard!.instantiateViewController(withIdentifier: "Records") as! RecordsViewController
//        self.recordsViewController.records = findRecords(data: self.date)
        recordsViewController.date = date
        return recordsViewController
    }
    
    @objc func onLeftBarButtonClicked(notification: Notification) -> Void {
//        self.date = self.date! - (60 * 60 * 24)
        date = notification.userInfo!["date"] as! Date
        self.setViewControllers([getViewController(date)], direction: .reverse, animated: true, completion: nil)
//        NotificationCenter.default.post(name: .PageBackward, object: nil)
    }
    
    @objc func onRightBarButtonClicked(notification: Notification) -> Void {
//        self.date = self.date! + (60 * 60 * 24)
        date = notification.userInfo!["date"] as! Date
        self.setViewControllers([getViewController(date)], direction: .forward, animated: true, completion: nil)
//        NotificationCenter.default.post(name: .PageForward, object: nil)
    }

}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        self.date = self.date! - (60 * 60 * 24)
        date = (viewController as! RecordsViewController).date! - (60 * 60 * 24)
        
//        let userInfoDict = ["date": date]
//        NotificationCenter.default.post(name: .PageBackward, object: nil, userInfo: userInfoDict)
        
        return getViewController(date)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        self.date = self.date! + (60 * 60 * 24)
        date = (viewController as! RecordsViewController).date! + (60 * 60 * 24)
        
//        let userInfoDict = ["date": date]
//        NotificationCenter.default.post(name: .PageForward, object: nil, userInfo: userInfoDict)
        
        return getViewController(date)
    }
}

extension Notification.Name {
    static let PageForward = Notification.Name("PageForward")
    static let PageBackward = Notification.Name("PageBackward")
}
