//
//  RecordsViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/09.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var records: [(time: String, image: String?, name: String?, description: String?)] = []
    
    var date: Date?
    
    var token: NotificationToken?
    
    var results: Results<Record>?

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = results![indexPath.row]
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HHmm", options: 0, locale: Locale.current)
        label1.text = formatter.string(from: record.dateTime!)

        let imageView = cell.contentView.viewWithTag(2) as! UIImageView
        imageView.contentMode = .scaleAspectFit
        let cellImage = UIImage(named: Command.image(id: Int(record.commandId!)!)!)
        imageView.image = cellImage

        let label2 = cell.contentView.viewWithTag(3) as! UILabel
        label2.text = Command.name(id: Int(record.commandId!)!)

        let label3 = cell.contentView.viewWithTag(4) as! UILabel
        label3.text = record.value1

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = results![indexPath.row]
        switch record.commandId {
        case "1":
            let storyboard: UIStoryboard = self.storyboard!
            let editMilkViewController = storyboard.instantiateViewController(withIdentifier: "EditMilkViewController") as! EditMilkViewController
            editMilkViewController.id = record.id
            self.present(editMilkViewController, animated: true, completion: nil)
        default:
            print("default")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("### viewDidLoad ###")

        if let unwrappedDate = date {
            let realm = try! Realm()
            let from = Calendar.current.startOfDay(for: unwrappedDate)
            let to = from + 60 * 60 * 24
            results = realm.objects(Record.self).filter("%@ <= dateTime AND dateTime <= %a", from, to)

//            token = results!.observe { _ in
//                self.tableView.reloadData()
//                print("***", self.results!.count, "***")
//                self.tableView.scrollToRow(at: IndexPath(row: self.results!.count, section: 0), at: .top, animated: false)
//            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("### viewDidAppear ###")
        
        if let unwrappedDate = date {
            let realm = try! Realm()
            let from = Calendar.current.startOfDay(for: unwrappedDate)
            let to = from + 60 * 60 * 24
            results = realm.objects(Record.self).filter("%@ <= dateTime AND dateTime <= %a", from, to)
            
            token = results!.observe { _ in
                self.tableView.reloadData()
            }
        }
        
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RecordsViewDidAppear, object: nil, userInfo: userInfoDict)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("### viewDedDisaaperw ###")
        if let unwrappedToken = token {
            unwrappedToken.invalidate()
        }
    }
}

extension Notification.Name {
    static let RecordsViewDidAppear = Notification.Name("RecordsViewDidAppear")
}
