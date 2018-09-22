//
//  TemplateViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2018/07/23.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import UIKit
import Firebase

class TemplateViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView1: UITableView!
    
    let photos = ["icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon", "icon"]
    
    var pageIndex: Int = 0

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad")
        // Do any additional setup after loading the view.
        
        tableView1.dataSource = self
        tableView1.delegate = self

        tableView1.isScrollEnabled = false
        tableView1.allowsSelection = false
        
//        FirebaseApp.configure()
//        let db = Firestore.firestore()
//        
//        var ref: DocumentReference? = nil
//        ref = db.collection("users").addDocument(data: [
//            "first": "Ada",
//            "last": "Lovelace",
//            "born": 1815
//        ]) { err in
//            if let err = err {
//                print("Error adding document: \(err)")
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//            }
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
//        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
//        let cellImage = UIImage(named: photos[indexPath.row])
//        imageView.image = cellImage
        let button = cell.contentView.viewWithTag(1) as! UIButton
        let cellImage = UIImage(named: photos[indexPath.row])
        button.setBackgroundImage(cellImage, for: .normal)
        button.setTitle(photos[indexPath.row], for: .normal)
        button.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0), for: .normal)
        button.addTarget(self, action: #selector(onClicked), for: .touchUpInside)
        let label = cell.contentView.viewWithTag(2) as! UILabel
        label.text = photos[indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    @objc func onClicked(sender: UIButton!) {
        print("Button Clicked:", sender.currentTitle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        let label1 = cell.contentView.viewWithTag(1) as! UILabel
        label1.text = indexPath.row.description
        let label2 = cell.contentView.viewWithTag(2) as! UILabel
        label2.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let imageView1 = cell.contentView.viewWithTag(3) as! UIImageView
        imageView1.contentMode = .scaleAspectFit
        let image1 = UIImage(named: "icon")
        imageView1.image = image1
        let imageView2 = cell.contentView.viewWithTag(4) as! UIImageView
        imageView2.contentMode = .scaleAspectFit
        let image2 = UIImage(named: "icon")
        imageView2.image = image2
        let imageView3 = cell.contentView.viewWithTag(5) as! UIImageView
        imageView3.contentMode = .scaleAspectFit
        let image3 = UIImage(named: "icon")
        imageView3.image = image3
        print("cell.height", cell.frame.height)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 24
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return resolveCellHeight(tableView: tableView)
    }
    
    func resolveCellHeight(tableView: UITableView) -> CGFloat {
        let tableHeight: CGFloat = tableView.frame.height
        let cellHeight: CGFloat = tableHeight / 24
        return cellHeight
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
