//
//  PageViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/24.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    public private(set) var pageIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewControllers([getTemplate()], direction: .forward, animated: true, completion: nil)
        self.dataSource = self
        print("pageView.viewDidoad")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTemplate() -> TemplateViewController {
        let template =  storyboard!.instantiateViewController(withIdentifier: "TemplateViewController") as! TemplateViewController
        template.pageIndex = self.pageIndex
        return template
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

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.pageIndex = self.pageIndex - 1
        return getTemplate()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.pageIndex = self.pageIndex + 1
        return getTemplate()
    }
}
