//
//  StatisticsViewController.swift
//  BeNiMei
//
//  Created by user149927 on 2/27/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Charts
import Firebase

class StatisticsViewController: UIViewController {

    
    @IBOutlet weak var myPieChartView: PieChartView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var sellPriceLabel: UILabel!
    
    struct product {
        var name = String()
        var price = String()
        var date = String()
    }
    struct productNew {
        var name = String()
        var totalPrice = Int()
        var number = Int()
    }
    var filteredDatas : [product] = [product]()
    var datas : [product] = [product]()
    
    let refHistory : DatabaseReference = Database.database().reference().child("customer")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "資料統計"
        refHistory.queryOrderedByKey().observe(.childAdded) { (snapshot) in
            var nameArr : [String] = [String]()
            var priceArr : [String] = [String]()
            var date : String = String()
            var data = product()
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    if item.key == "service"{
                        nameArr = item.value as! [String]
                    }
                    else if item.key == "eachPrice"{
                        priceArr = item.value as! [String]
                    }
                    else if item.key == "date"{
                        date = item.value as! String
                    }
                }
                for i in 0..<nameArr.count{
                    data.name = nameArr[i]
                    data.price = priceArr[i]
                    data.date = date
                    self.datas.append(data)
                }
            }
            let calculatedData = self.dataCalculation(data: self.datas)
            self.updateChartsData(cData: calculatedData)
        }
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            startTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 27)
            endTimeButton.titleLabel?.font = UIFont.systemFont(ofSize: 27)
            sellPriceLabel.font = UIFont.systemFont(ofSize: 27)
            totalPriceLabel.font = UIFont.systemFont(ofSize: 27)
            myPieChartView.chartDescription?.font = UIFont.systemFont(ofSize: 22)
            myPieChartView.entryLabelFont = UIFont.systemFont(ofSize: 24)
        }
    }
    
    func dataCalculation(data:[product]) -> [productNew]{
        var newData : [productNew] = [productNew]()
        newData.append(productNew(name: data[0].name, totalPrice: Int(data[0].price)!, number: 1))
        for i in 1..<data.count{
            var exist : Bool = false
            for j in 0..<newData.count{
                if newData[j].name == data[i].name {
                    exist = true
                    newData[j].totalPrice = newData[j].totalPrice + Int(data[i].price)!
                    newData[j].number = newData[j].number + 1
                    break
                }
            }
            if !exist {
                newData.append(productNew(name: data[i].name, totalPrice: Int(data[i].price)!, number: 1))
            }
        }
        return newData
    }
    
    func createColor(colorNumber : Int) -> [UIColor] {
        var colors = [UIColor]()
        for i in 0..<colorNumber {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    
    func updateChartsData(cData:[productNew]){
        let colors = createColor(colorNumber: cData.count)
        var sum = 0
        var dataEntries: [PieChartDataEntry] = []
        for i in 0..<cData.count {
            let dataEntry = PieChartDataEntry(value: Double(cData[i].number), label: cData[i].name)
            sum = sum + cData[i].totalPrice
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
        chartDataSet.colors = colors
        chartDataSet.description
        let charData = PieChartData(dataSet: chartDataSet)
        myPieChartView.data = charData
        
        self.totalPriceLabel.text = String(sum)
    }

    @IBAction func startTimeButton(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        datePicker.locale = Locale(identifier: "zh_TW")
        //datePicker.datePickerMode = UIDatePicker.Mode.date
        //datePicker.minuteInterval = 10
        vc.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "請選擇開始時間", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let dateObj = dateFormatter.string(from: datePicker.date)
            self.startTimeButton.setTitle(dateObj, for: .normal)
            
            if self.startTimeButton.currentTitle != "開始" && self.endTimeButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.startTimeButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.endTimeButton.currentTitle ?? "0") as! NSDate
                self.filteredDatas = self.datas.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                        /*
                         if (dateStart?.compare(compaerDate!) == .orderedDescending && dateEnd?.compare(compaerDate!) == .orderedAscending){
                         return true
                         }*/
                    else {
                        return false
                    }
                } )
                if self.filteredDatas.isEmpty{
                    self.updateChartsData(cData: [productNew(name: "無資料", totalPrice: 0, number: 1)])
                }
                else {
                    let calculatedData = self.dataCalculation(data: self.filteredDatas)
                    self.updateChartsData(cData: calculatedData)
                }
            }
        }))
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = startTimeButton
                currentPopoverpresentioncontroller.sourceRect = startTimeButton.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func endTimeButton(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        datePicker.locale = Locale(identifier: "zh_TW")
        //datePicker.datePickerMode = UIDatePicker.Mode.date
        //datePicker.minuteInterval = 10
        vc.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "請選擇開始時間", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let dateObj = dateFormatter.string(from: datePicker.date)
            self.endTimeButton.setTitle(dateObj, for: .normal)
            
            if self.startTimeButton.currentTitle != "開始" && self.endTimeButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.startTimeButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.endTimeButton.currentTitle ?? "0") as! NSDate
                self.filteredDatas = self.datas.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                        /*
                         if (dateStart?.compare(compaerDate!) == .orderedDescending && dateEnd?.compare(compaerDate!) == .orderedAscending){
                         return true
                         }*/
                    else {
                        return false
                    }
                } )
                if self.filteredDatas.isEmpty{
                    self.updateChartsData(cData: [productNew(name: "無資料", totalPrice: 0, number: 1)])
                }
                else {
                    let calculatedData = self.dataCalculation(data: self.filteredDatas)
                    self.updateChartsData(cData: calculatedData)
                }
            }
        }))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = endTimeButton
                currentPopoverpresentioncontroller.sourceRect = endTimeButton.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
}
