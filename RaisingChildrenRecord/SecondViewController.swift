//
//  SecondViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/12.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

import RealmSwift

import CustomRealmObject

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var token: NotificationToken?
    
    var sections: [(header: String, cells: [(label1: String, label2: String)])]
        = [(header: "赤ちゃんを切り替える", cells: []),
           (header: "赤ちゃんを編集する", cells: [])]
    var babies: Array<Baby> = []
    
    // MARK: - UIViewController LifeCycle Callback
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        
        let realm = try! Realm()
        let results = realm.objects(Baby.self)
        
        token = results.observe { _ in
            self.tableView.reloadData()
        }
        
        babies = []
        for result in results {
            babies.append(result)
        }
        
        sections[0].cells = []
        sections[1].cells = []
        
        for baby in babies {
            let name = baby.name
            
            let f = DateFormatter()
            f.locale = Locale(identifier: "ja_JP")
            f.dateStyle = .long
            f.timeStyle = .none
            let born = f.string(from: baby.born) + "生まれ"
            
            sections[0].cells.append((label1: name, label2: born))
            sections[1].cells.append((label1: name, label2: born))
        }
        
        sections[1].cells.append((label1: "赤ちゃん追加", label2: ""))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let unwrappedToken = self.token {
            unwrappedToken.invalidate()
        }
    }
    
    
    // MARK: - UITableViewDateSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.text = sections[section].cells[row].label1
            let label2 = cell.viewWithTag(2) as! UILabel
            label2.text = sections[section].cells[row].label2
            cell.accessoryType = isSelected(babies[row].id) ? .checkmark : .none

        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            let label1 = cell.viewWithTag(1) as! UILabel
            label1.text = sections[section].cells[row].label1
            let label2 = cell.viewWithTag(2) as! UILabel
            label2.text = sections[section].cells[row].label2
            
        default:
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            if (!isSelected(babies[row].id)) {
                for row in 0..<sections[0].cells.count {
                    let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0))!
                    cell.accessoryType = .none
                }
            
                let selectedCell = tableView.cellForRow(at: indexPath)!
                selectedCell.accessoryType = .checkmark
            
                select(babies[row].id)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case 1:
            switch row {
            case sections[1].cells.count - 1:
                // to AddBabyScreen
                let storyboard: UIStoryboard = self.storyboard!
                let editBabyViewController = storyboard.instantiateViewController(withIdentifier: "EditBabyViewController") as! EditBabyViewController
                editBabyViewController.baby = nil
                self.present(editBabyViewController, animated: true, completion: nil)
            
            default:
                // to EditBabyScreen
                let storyboard: UIStoryboard = self.storyboard!
                let editBabyViewController = storyboard.instantiateViewController(withIdentifier: "EditBabyViewController") as! EditBabyViewController
                editBabyViewController.baby = babies[row]
                self.present(editBabyViewController, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    // MARK: - Utility
    func isSelected(_ babyId: String) -> Bool {
        let currentBabyId = UserDefaults.standard.object(forKey: UserDefaultsKey.BabyId.rawValue) as? String
        if let unwrappedCurrentBabyId = currentBabyId {
            return unwrappedCurrentBabyId == babyId
        } else {
            let firstBabyId = babies.first!.id
            select(firstBabyId)
            return firstBabyId == babyId
        }
    }
    
    func select(_ babyId: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.register(defaults: [UserDefaultsKey.BabyId.rawValue: babyId])
    }
}

