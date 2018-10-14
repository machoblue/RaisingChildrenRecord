//
//  RecordsViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/09/09.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import CustomRealmObject

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
            break
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
        
        guard let date = self.date else { return }
        
        let realm = try! Realm()
        
        let babyId = UserDefaults.standard.object(forKey: UserDefaultsKey.BabyId.rawValue) as? String ?? realm.objects(Baby.self).first!.id
        
        let from = Calendar.current.startOfDay(for: date)
        let to = from + 60 * 60 * 24
        results = realm.objects(Record.self).filter("%@ <= dateTime AND dateTime <= %a AND babyId == %@", from, to, babyId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        token = results!.observe { _ in
            print("### RecordViewController.viewDidLoad.observe ###")
            self.tableView.reloadData()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleViewClicked(notification:)), name: Notification.Name.TitleViewClicked, object: nil)
        
        let userInfoDict = ["date": self.date!]
        NotificationCenter.default.post(name: .RecordsViewDidAppear, object: nil, userInfo: userInfoDict)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let unwrappedToken = token {
            unwrappedToken.invalidate()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    @objc func onTitleViewClicked(notification: Notification) -> Void {
        guard let babyId = notification.userInfo?["babyId"] as? String else { return }
        guard let date = self.date else { return }
        
        let realm = try! Realm()
        let from = Calendar.current.startOfDay(for: date)
        let to = from + 60 * 60 * 24
        results = realm.objects(Record.self).filter("%@ <= dateTime AND dateTime <= %a AND babyId == %@", from, to, babyId)
        
        if let token = self.token {
            token.invalidate()
        }

        token = results!.observe { _ in
            self.tableView.reloadData()
        }
    }
}

extension Notification.Name {
    static let RecordsViewDidAppear = Notification.Name("RecordsViewDidAppear")
}
