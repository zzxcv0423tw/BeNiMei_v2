//
//  CustomerInfo.swift
//  BeNiMei
//
//  Created by user149927 on 1/10/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class CustomerInfo: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    @IBOutlet weak var cuNameF: UITextField!
    @IBOutlet weak var cuPhoneF: UITextField!
    @IBOutlet weak var cuDateF: UIDatePicker!
    @IBOutlet weak var cuBeauticianF: UITextField!
    @IBOutlet weak var selectBeauticianButton: UIButton!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    var orderedNameArray = [String]()
    var orderePriceArray = [String]()
    var beauticians = ["AAA","BBB","CCC"]
    var pickerSelected = String()
    
    let dateValue = DateFormatter()
    var dateValueS: String = ""
    
    @IBAction func DatePickerAct(_ sender: UIDatePicker) {
        dateValue.dateFormat = "yy/MM/dd HH:mm" // 設定要顯示在Text Field的日期時間格式
        dateValueS = dateValue.string(from: cuDateF.date) // 更新Text Field的內容
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let intArray = orderePriceArray.map { Int($0)!} // [11, 43, 26, 11, 45, 40]
        if segue.identifier == "Send" {
            let secondVC = segue.destination as! CheckService
            secondVC.cuName = cuNameF.text!
            secondVC.cuPhone = cuPhoneF.text!
            secondVC.cuBeautician = selectBeauticianButton.currentTitle!
            secondVC.cuDate = dateValueS
            secondVC.orderedNameArrayc = orderedNameArray
            secondVC.priceArrayc = intArray
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dataLabel.backgroundColor = 	UIColor(patternImage: UIImage(named: "bg_150_200")!)
        beauticians = []
        let ref  = Database.database().reference().child("beautician")
        ref.queryOrderedByKey().observe(.childAdded) { (snapshot) in
            var beauticianName = String()
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    if item.key == "name"{
                        beauticianName = item.value as! String
                    }
                }
                self.beauticians.append(beauticianName)
            }
        }
        
        dateValue.dateFormat = "yy/MM/dd HH:mm" // 設定要顯示在Text Field的日期時間格式
        dateValueS = dateValue.string(from: cuDateF.date) // 更新Text Field的內容
        
    }
    @IBAction func popUpBeauticianPicker(_ sender: Any) {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        picker.delegate = self
        picker.dataSource = self
        
        vc.view.addSubview(picker)
        picker.selectRow(beauticians.count / 2, inComponent: 0, animated: false)
        
        let alert = UIAlertController(title: "請選擇美容師", message: nil, preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel
            , handler:  nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            self.selectBeauticianButton.setTitle(self.pickerSelected, for: .normal)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return beauticians.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerSelected = beauticians[row]
        return beauticians[row % beauticians.count]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelected = beauticians[row]
    }
}

