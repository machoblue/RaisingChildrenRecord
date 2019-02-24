//
//  MonthViewController.swift
//  RaisingChildrenRecord
//
//  Created by 松島勇貴 on 2019/02/09.
//  Copyright © 2019年 松島勇貴. All rights reserved.
//

import UIKit

import Shared

class MonthViewController: UIViewController {
    typealias CellModel = (type: CellType, date: Date, reuseIdentifier: ReuseIdentifier, summaries: [(image: String, description: String)])
    enum CellType: String {
        case Date
        case Header
    }
    enum ReuseIdentifier: String {
        case DateCell
        case HeaderCell
    }
    
    var cellModels = [CellModel]()
    
    var date = Date()
    var baby: BabyModel!
    
    var recordDao: RecordDao!
    var recordObserver: RecordObserver!

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordDao = RecordDaoFactory.shared.createRecordDao(.Local)
        recordObserver = RecordObserverFactory.shared.createRecordObserver(.Local)
        
        cellModels = createCellModels(baby: baby, date: date) // ページをめくる時にサマリーを表示するため
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTitleViewClicked(notification:)), name: Notification.Name.CalendarTitleViewClicked, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let calendarFirstDate = UIUtils.shared.getFirstDateOfMonthCalendar(date: date)
        let from = calendarFirstDate
        let to = Date(timeInterval: TimeInterval(60 * 60 * 24 * 42), since: from)
        recordObserver.observe(babyId: baby.id, from: from, to: to) { _ in // 詳細画面から戻ってきた時に記録を反映させるため
            self.cellModels = self.createCellModels(baby: self.baby, date: self.date)
            self.collectionView.reloadData()
        }
    }
    
    func createCellModels(baby: BabyModel, date: Date) -> [CellModel] {
        var cellModels = [CellModel]()
        
        let calendarFirstDate = UIUtils.shared.getFirstDateOfMonthCalendar(date: date)
        
        for i in 0...6 {
            let date = Date(timeInterval: TimeInterval(i * 60 * 60 * 24), since: calendarFirstDate)
            cellModels.append(CellModel(type: .Header, date: date, reuseIdentifier: .HeaderCell, summaries: []))
        }
        
        for i in 0...41 {
            let date = Date(timeInterval: TimeInterval(i * 60 * 60 * 24), since: calendarFirstDate)
            
            let from = date
            let to = Date(timeInterval: TimeInterval(60 * 60 * 24), since: from)
            let records = recordDao.find(babyId: baby.id, from: from, to: to)
            let summaries = createSummaries(records: records, baby: baby, from: from, to: to)
            
            cellModels.append(CellModel(type: .Date, date: date, reuseIdentifier: .DateCell, summaries: summaries))
        }
        return cellModels
    }

    func createSummaries(records: [RecordModel], baby: BabyModel, from: Date, to: Date) -> [(image: String, description: String)] {
        var summaries: [(image: String, description: String)] = []
        
        var milkTotal = 0
        var breastTotal = 0
        var temperatureMax = Float(0.0)
        var pooTotal = 0
        var sleepTotal = 0.0
        var sleepPoint: Date?
        
        for i in 0..<records.count {
            let record = records[i]
            switch Commands.Identifier(rawValue: record.commandId)! {
            case .milk:
                milkTotal += record.number1
            case .breast:
                breastTotal += record.number1
            case .temperature:
                temperatureMax = max(temperatureMax, record.decimal1)
            case .poo:
                pooTotal += 1
            case .sleep:
                guard sleepPoint == nil else { break }
                sleepPoint = record.dateTime
            case .awake:
                let timeInterval = record.dateTime.timeIntervalSince(sleepPoint ?? from)
                sleepTotal += timeInterval / (60 * 60.0)
                sleepPoint = nil
            default:
                break
            }
        }
        
        // 寝る　の後　起きる　を押していない場合（寝るを押しっぱなし）
        if let sleepPoint = sleepPoint {
            let now = Date()
            
            // 過去
            if sleepPoint < now {
                let today000000 = UIUtils.shared.getYYYYMMDD000000Date(now)
                
                // 昨日以前
                if sleepPoint < today000000 {
                    let timeInterval = to.timeIntervalSince(sleepPoint)
                    sleepTotal += timeInterval / (60 * 60.0)
                    
                // 今日〜今
                } else {
                    let timeInterval = now.timeIntervalSince(sleepPoint)
                    sleepTotal += timeInterval / (60 * 60.0)
                }
              
            // 未来
            } else {
                // do nothing
            }
        }
        
        if milkTotal > 0 {
            summaries.append((image: "milk", description: "\(milkTotal)ml"))
        }
        if breastTotal > 0 {
            summaries.append((image: "breast", description: "\(breastTotal)分"))
        }
        if temperatureMax > 0.0 {
            summaries.append((image: "temperature", description: "\(temperatureMax)℃"))
        }
        if pooTotal > 0 {
            summaries.append((image: "poo", description: "\(pooTotal)回"))
        }
        if sleepTotal > 0 {
            summaries.append((image: "sleep", description: "\(round(sleepTotal * 10) / 10.0)時間"))
        }
        
        return summaries
    }
    
    // MARK: - Event
    @objc func onTitleViewClicked(notification: Notification) -> Void {
        guard let babyId = notification.userInfo?["babyId"] as? String else { return }
        baby = BabyDaoFactory.shared.createBabyDao(.Local).find(babyId)
        cellModels = self.createCellModels(baby: baby, date: date)
        collectionView.reloadData()
    }
}

extension MonthViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.reuseIdentifier {
        case .DateCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellModel.reuseIdentifier.rawValue, for: indexPath) as! DateCell
            
            cell.clear() // imageView.imageやlabel.textが残ってしまうので、clear
            
            cell.label.text = Calendar.current.component(.day, from: cellModel.date).description
            
            // gray the day of other month
            if !isThisMonth(cellModel.date) {
                cell.label.textColor = UIColor.lightGray
            }
            
            // highlight today
            if isToday(cellModel.date) {
                cell.label.layer.cornerRadius = cell.label.frame.width / 2
                cell.label.layer.masksToBounds = true
                cell.label.backgroundColor = UIColor.orange
                cell.label.textColor = UIColor.white
            }
            
            for i in 0...4 {
                guard i < cellModel.summaries.count else { continue }
                let summary = cellModel.summaries[i]
                switch i {
                case 0:
                    cell.image1.image = UIImage(named: summary.image)
                    cell.description1.text = summary.description
                case 1:
                    cell.image2.image = UIImage(named: summary.image)
                    cell.description2.text = summary.description
                case 2:
                    cell.image3.image = UIImage(named: summary.image)
                    cell.description3.text = summary.description
                case 3:
                    cell.image4.image = UIImage(named: summary.image)
                    cell.description4.text = summary.description
                case 4:
                    cell.image5.image = UIImage(named: summary.image)
                    cell.description5.text = summary.description
                default:
                    break
                }
            }
            
            return cell
        case .HeaderCell:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellModel.reuseIdentifier.rawValue, for: indexPath) as! HeaderCell
            
            cell.label.text = UIUtils.shared.formatToEEEEE(cellModel.date)
            return cell
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        let result = Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedSame
        return result
    }
    
    func isThisMonth(_ date: Date) -> Bool {
        let thisMonth = Calendar.current.dateComponents([.month], from: self.date)
        let month = Calendar.current.dateComponents([.month], from: date)
        return thisMonth == month
    }
    
}

extension MonthViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.reuseIdentifier {
        case .DateCell:
            let firstViewController = self.storyboard?.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
            firstViewController.date = cellModel.date
            
            let backButtonItem = UIBarButtonItem(title: UIUtils.shared.formatToMMOrYYYYMM(date), style: .plain, target: nil, action: nil)
            navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
            
            navigationController?.pushViewController(firstViewController, animated: true)

        case .HeaderCell:
            break
        }
    }
}

extension MonthViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let headerHeight = CGFloat(40)
//        let width = floor(collectionView.contentSize.width / 7)
        let width = floor(collectionView.frame.size.width / 7)
        
        let cellModel = cellModels[indexPath.row]
        switch cellModel.reuseIdentifier {
        case .DateCell:
            let height = (collectionView.visibleSize.height - headerHeight) / 6
            return CGSize(width: width, height: height)
        case .HeaderCell:
            let height = headerHeight
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}

class DateCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var description1: UILabel!
    @IBOutlet weak var description2: UILabel!
    @IBOutlet weak var description3: UILabel!
    @IBOutlet weak var description4: UILabel!
    @IBOutlet weak var description5: UILabel!
    func clear() {
        label.text = nil
        label.backgroundColor = .clear
        label.textColor = .darkGray
        image1.image = nil
        image2.image = nil
        image3.image = nil
        image4.image = nil
        image5.image = nil
        description1.text = nil
        description2.text = nil
        description3.text = nil
        description4.text = nil
        description5.text = nil
    }
}

class HeaderCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class CalendarCollectionView: UICollectionView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let path = UIBezierPath()
        
        let headerHeight = CGFloat(40.0)
        let rowHeight = (frame.size.height - headerHeight) / 6
        let columnWidth = frame.size.width / 7
        
        // draw horizontal line
        for row in 0...5 {
            let y = headerHeight + CGFloat(row) * rowHeight
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: frame.size.width, y: y))
        }
        
        // draw vertical line
        for column in 1...6 {
            let x = columnWidth * CGFloat(column)
            path.move(to: CGPoint(x: x, y: headerHeight))
            path.addLine(to: CGPoint(x: x, y: frame.size.height))
        }
        
        path.lineWidth = 0.25
        UIColor.lightGray.setStroke()
        
        path.stroke()
    }
}
