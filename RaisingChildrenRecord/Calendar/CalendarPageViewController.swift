//
//  CalendarPageViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/02/09.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

import Shared

class CalendarPageViewController: UIPageViewController {
    var date = Date()
    
    var babyDao: BabyDao!
    var babies: [BabyModel]!
    var baby: BabyModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        // disable transit on tap
        for recognizer in self.gestureRecognizers {
            if recognizer is UITapGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
        
        babyDao = BabyDaoFactory.shared.createBabyDao(.Local)
        
        babies = babyDao.findAll()
        if let currentBabyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String,
            let currentBaby = (babies.filter { $0.id == currentBabyId }).first {
            self.baby = currentBaby
        } else {
            self.baby = babies.first!
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
        }
        
        self.setViewControllers([getViewController(date)], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        babies = babyDao.findAll()
        if let currentBabyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String,
            let currentBaby = (babies.filter { $0.id == currentBabyId }).first {
            self.baby = currentBaby
        } else {
            self.baby = babies.first!
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
        }
        
        initTitleView(date: date, baby: baby)
    }

    func getViewController(_ date: Date) -> MonthViewController {
        let monthViewController =  storyboard!.instantiateViewController(withIdentifier: "Month") as! MonthViewController
        monthViewController.date = date
        monthViewController.baby = baby
        return monthViewController
    }
    
    func format(_ date: Date) -> String {
        return UIUtils.shared.formatToMMOrYYYYMM(date)
    }
    
    func initTitleView(date: Date, baby: BabyModel) {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 60)
        let calendarTitleView = CalendarTitleView(frame: frame)
        calendarTitleView.yearAndMonth.text = format(date)
        calendarTitleView.name.text = baby.name
        calendarTitleView.age.text = UIUtils.shared.resolveAge(born: baby.born, now: date)
        self.navigationItem.titleView = calendarTitleView
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTitleViewTapped(_:)))
        navigationItem.titleView?.addGestureRecognizer(gesture)
    }
    
    func reloadTitleView(baby: BabyModel, date: Date) {
        guard let calendarTitleView = navigationItem.titleView as? CalendarTitleView else { return }
        calendarTitleView.name.text = baby.name
        let firstDate = UIUtils.shared.getFirstDateOfMonthCalendar(date: date)
        calendarTitleView.age.text = UIUtils.shared.resolveAge(born: baby.born, now: firstDate)
        calendarTitleView.yearAndMonth.text = format(date)
    }
    
    @objc func onTitleViewTapped(_ sender: UITapGestureRecognizer) {
        babies = babyDao.findAll()
        if let currentBabyId = UserDefaults.standard.object(forKey: UserDefaults.Keys.BabyId.rawValue) as? String,
            let _ = (babies.filter { $0.id == currentBabyId }).first {
            let index = ((babies.firstIndex { $0.id == currentBabyId })! + 1) % babies.count
            self.baby = babies[index]
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
        } else {
            self.baby = babies.first!
            UserDefaults.standard.register(defaults: [UserDefaults.Keys.BabyId.rawValue: baby.id])
        }
        
        self.reloadTitleView(baby: baby, date: date)
        
        let userInfoDict = ["babyId": baby.id]
        NotificationCenter.default.post(name: .CalendarTitleViewClicked, object: nil, userInfo: userInfoDict)
    }
}

extension CalendarPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentDate = (viewController as! MonthViewController).date
        let add = DateComponents(month: -1)
        let date = Calendar.current.date(byAdding: add, to: currentDate)
                
        return getViewController(date!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentDate = (viewController as! MonthViewController).date
        let add = DateComponents(month: 1)
        let date = Calendar.current.date(byAdding: add, to: currentDate)

        return getViewController(date!)
    }
}

extension CalendarPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let monthViewController = pendingViewControllers[0] as? MonthViewController else { return }
        date = monthViewController.date
        reloadTitleView(baby: baby, date: date)
    }
}

extension Notification.Name {
    static let CalendarTitleViewClicked = Notification.Name("CalendarTitleViewClicked")
}
