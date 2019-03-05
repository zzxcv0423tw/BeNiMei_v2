//
//  CheckService.swift
//  BeNiMei
//
//  Created by user149927 on 1/11/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class CheckService: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var ATableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    
    var cuName: String = ""
    var cuPhone: String = ""
    var cuDate: String = ""
    var cuBeautician: String = ""
    
    var ref: DatabaseReference! = Database.database().reference()
    var refWriteDBFild: DatabaseReference! = Database.database().reference().child("customer")
    
    var orderedNameArrayc = ["無"]
    var priceArrayc = [0]
    //submit前確認
    @IBAction func alert(_ sender: Any) {
        let alert = UIAlertController(title: "確認", message: "確定送出？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
            
            var customerInfo: [String : AnyObject] = [String : AnyObject]()
            customerInfo["name"] = self.cuName as AnyObject
            customerInfo["phone"] = self.cuPhone as AnyObject
            customerInfo["date"] = self.cuDate as AnyObject
            customerInfo["beautician"] = self.cuBeautician as AnyObject
            customerInfo["service"] = self.orderedNameArrayc as AnyObject
            customerInfo["price"] = self.totalPrice.text as AnyObject
            var priceArraycStr = self.priceArrayc.map { String($0) }
            customerInfo["eachPrice"] = priceArraycStr as AnyObject
            
            let childRef = self.refWriteDBFild.childByAutoId() // 隨機生成的節點唯一識別碼，用來當儲存時的key值
            let customerInfoReference = self.refWriteDBFild.child(childRef.key ?? "000")
            
            customerInfoReference.updateChildValues(customerInfo) { (err, reff) in
                if err != nil{
                    print("err： \(err!)")
                    return
                }
                
                print(reff.description())
            }
            
            
                //回到根目錄
                self.navigationController?.popToRootViewController(animated: true)
            }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //告知tableView需要顯示多少列
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedNameArrayc.count
    }
    //告知tableView需要顯示什麼
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.serviceLabel.text = orderedNameArrayc[indexPath.row]
        cell.priceLabel.text = String( priceArrayc[indexPath.row])
        return cell
    }
    
    
    @IBOutlet weak var checkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        totalPrice.text = String(priceArrayc.reduce(0, +))
        
        ATableView.delegate = self
        ATableView.dataSource = self
        
        checkLabel.backgroundColor =     UIColor(patternImage: UIImage(named: "bg_150_200")!)
        
        print(cuName)
        print(cuPhone)
        print(cuBeautician)
        print(cuDate)
    }
    
}
