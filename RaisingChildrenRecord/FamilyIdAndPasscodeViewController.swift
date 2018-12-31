//
//  FamilyIdAndPasscodeViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/10/05.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit

class FamilyIdAndPasscodeViewController: UIViewController {
    typealias SectionModel = (title: String, rowCount: Int, cellReuseIdentifier: String, footer: String)
    let sections: [SectionModel] = [
        SectionModel("家族ID", 1, "LabelCell", ""),
        SectionModel("パスコード", 1, "LabelCell", "この家族IDとパスコードを共有相手の端末で入力してください。"),
    ]

    var familyIdText: String!
    var passcodeText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onLeftBarButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension FamilyIdAndPasscodeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("*** tableVie3wCell" )
        let sectionModel = sections[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionModel.cellReuseIdentifier, for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = familyIdText
        case 1:
            cell.textLabel?.text = passcodeText
        default:
            break
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }
}

extension FamilyIdAndPasscodeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
