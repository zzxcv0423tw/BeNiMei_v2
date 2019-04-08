//
//  EditItemViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/26/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class EditItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var aTableView: UITableView!
    
    struct item {
        var key = String()
        var name = String()
        var price = String()
        var description = String()
        var imagePath = String()
    }
    
    let ref : DatabaseReference! = Database.database().reference()
    
    var itemArray = [item]()
    var serviceArray = [item]()
    var beauticianArray = [item]()
    var addPerchaseArray = [item]()
    var typeSegFlag : Int8 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "項目列表"
        self.hideKeyboardWhenTappedAround() 
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(callAddItemView))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        // Do any additional setup after loading the view.
        
        let refService : DatabaseReference! = Database.database().reference().child("service")
        let refBeautician : DatabaseReference! = Database.database().reference().child("beautician")
        let refAddPerchase : DatabaseReference! = Database.database().reference().child("addPerchase")
        
        refService.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            var serviceItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    serviceItem.key = snapshot.key
                    switch item.key {
                    case "name":
                        serviceItem.name = item.value as! String
                    case "price":
                        serviceItem.price = item.value as! String
                    case "description":
                        serviceItem.description = item.value as! String
                    case "imagePath":
                        //print("PATH:\(item.value)")
                        serviceItem.imagePath = item.value as! String
                    default:
                        break
                    }
                }
                self.serviceArray.append(serviceItem)
                //print("ARRAY:\(self.serviceArray)")
            }
            self.itemArray = self.serviceArray
            self.aTableView.reloadData()
        })
        refBeautician.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            var beauticianItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    beauticianItem.key = snapshot.key
                    if item.key == "name"{
                        beauticianItem.name = item.value as! String
                    } else if item.key == "imagePath" {
                        beauticianItem.imagePath = item.value as! String
                    }
                }
                self.beauticianArray.append(beauticianItem)
                //print(self.beauticianArray)
            }
            
        })
        refAddPerchase.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            var addPerchaseItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    addPerchaseItem.key = snapshot.key
                    switch item.key {
                    case "name":
                        addPerchaseItem.name = item.value as! String
                    case "price":
                        addPerchaseItem.price = item.value as! String
                    case "description":
                        addPerchaseItem.description = item.value as! String
                    case "imagePath":
                        addPerchaseItem.imagePath = item.value as! String
                    default:
                        break
                    }
                }
                self.addPerchaseArray.append(addPerchaseItem)
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        
        let refService : DatabaseReference! = Database.database().reference().child("service")
        let refBeautician : DatabaseReference! = Database.database().reference().child("beautician")
        let refAddPerchase : DatabaseReference! = Database.database().reference().child("addPerchase")
        if typeSegFlag == 0 {
            serviceArray = []
            refService.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                var serviceItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
                if let dictionaryData = snapshot.value as? [String:AnyObject]{
                    for item in dictionaryData{
                        serviceItem.key = snapshot.key
                        switch item.key {
                        case "name":
                            serviceItem.name = item.value as! String
                        case "price":
                            serviceItem.price = item.value as! String
                        case "description":
                            serviceItem.description = item.value as! String
                        case "imagePath":
                            serviceItem.imagePath = item.value as! String
                        default:
                            break
                        }
                    }
                    self.serviceArray.append(serviceItem)
                    //print(self.serviceArray)
                }
                self.itemArray = self.serviceArray
                self.aTableView.reloadData()
            })
        }
        else if typeSegFlag == 1 {
            beauticianArray = []
            refBeautician.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                var beauticianItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
                if let dictionaryData = snapshot.value as? [String:AnyObject]{
                    for item in dictionaryData{
                        beauticianItem.key = snapshot.key
                        if item.key == "name"{
                            beauticianItem.name = item.value as! String
                        } else if item.key == "imagePath"{
                            beauticianItem.imagePath = item.value as! String
                        }
                    }
                    self.beauticianArray.append(beauticianItem)
                    //print(self.beauticianArray)
                }
                self.itemArray = self.beauticianArray
                self.aTableView.reloadData()
            })
        }
        else if typeSegFlag == 2 {
            addPerchaseArray = []
            refAddPerchase.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                var addPerchaseItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
                if let dictionaryData = snapshot.value as? [String:AnyObject]{
                    for item in dictionaryData{
                        addPerchaseItem.key = snapshot.key
                        switch item.key {
                        case "name":
                            addPerchaseItem.name = item.value as! String
                        case "price":
                            addPerchaseItem.price = item.value as! String
                        case "description":
                            addPerchaseItem.description = item.value as! String
                        case "imagePath":
                            addPerchaseItem.imagePath = item.value as! String
                        default:
                            break
                        }
                    }
                    self.addPerchaseArray.append(addPerchaseItem)
                }
                self.itemArray = self.addPerchaseArray
                self.aTableView.reloadData()
            })
        }
    }
    
    @objc func callAddItemView(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "addItemView") as? AddItemViewController{
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func mySegChoose(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            typeSegFlag = 0
            itemArray = serviceArray
            aTableView.reloadData()
        }
        else if sender.selectedSegmentIndex == 1{
            typeSegFlag = 1
            itemArray = beauticianArray
            aTableView.reloadData()
        }
        else if sender.selectedSegmentIndex == 2{
            typeSegFlag = 2
            itemArray = addPerchaseArray
            aTableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditItemTableViewCell
        cell.itemLabel.text = itemArray[indexPath.row].name
        if typeSegFlag == 0{
            cell.editItemButton.isHidden = false
        }
        else if typeSegFlag == 1{
            cell.editItemButton.isHidden = true
        }
        else if typeSegFlag == 2{
            cell.editItemButton.isHidden = false
        }
        cell.deleteItemButton.tag = indexPath.row
        cell.deleteItemButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        
        cell.editItemButton.tag = indexPath.row
        cell.editItemButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        return cell
    }
    @objc func tapDeleteButton(sender: UIButton){
        //print(itemArray[sender.tag].key)
        if typeSegFlag == 0{
           let alert = UIAlertController(title: "確認", message: "確定要刪除服務項目『"+itemArray[sender.tag].name+"』？", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "確認", style: .default, handler: {action in
                //print("ITEMARRAY:\(self.itemArray[sender.tag].imagePath)")
                let desertRef = Storage.storage().reference().child("image").child(self.itemArray[sender.tag].imagePath)
                desertRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        //delete successful !
                    }
                })
                
                self.ref.child("service").child(self.itemArray[sender.tag].key).removeValue()
                self.serviceArray.remove(at: sender.tag)
                self.itemArray = self.serviceArray
                self.aTableView.reloadData()
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if typeSegFlag == 1{
            let alert = UIAlertController(title: "確認", message: "確定要刪除美容師『"+itemArray[sender.tag].name+"』？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "確認", style: .default, handler: {action in
                let desertRef = Storage.storage().reference().child("image").child(self.itemArray[sender.tag].imagePath)
                desertRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        //delete successful !
                    }
                })
                
                self.ref.child("beautician").child(self.itemArray[sender.tag].key).removeValue()
                self.beauticianArray.remove(at: sender.tag)
                self.itemArray = self.beauticianArray
                self.aTableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if typeSegFlag == 2{
            let alert = UIAlertController(title: "確認", message: "確定要刪除加購產品『"+itemArray[sender.tag].name+"』？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { action in
                let desertRef = Storage.storage().reference().child("image").child(self.itemArray[sender.tag].imagePath)
                desertRef.delete(completion: { (error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        //delete successful !
                    }
                })
                
                self.ref.child("addPerchase").child(self.itemArray[sender.tag].key).removeValue()
                self.addPerchaseArray.remove(at: sender.tag)
                self.itemArray = self.addPerchaseArray
                self.aTableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func login(sender: UIButton) {
        
        self.performSegue(withIdentifier: "sendEdit", sender: sender.tag)
        
        /*
        if let controller = storyboard?.instantiateViewController(withIdentifier: "editView") as? EditViewController{
            navigationController?.pushViewController(controller, animated: true)
        }
         */
        /*
        // 建立一個提示框
        let alertController = UIAlertController(
            title: "修改",
            message: nil,
            preferredStyle: .alert)
        let alertViewHeight:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view,
                                                           attribute: NSLayoutConstraint.Attribute.height,
                                                           relatedBy: NSLayoutConstraint.Relation.equal,
                                                           toItem: nil,
                                                           attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                           multiplier: 1,
                                                           constant: self.view.frame.height * 0.40)
        
        alertController.view.addConstraint(alertViewHeight);
        
        // 建立兩個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            
            let oneLineTextFieldHieght:NSLayoutConstraint = NSLayoutConstraint(item: textField,
                                                                               attribute: .height,
                                                                               relatedBy: .equal,
                                                                               toItem: nil,
                                                                               attribute: .notAnAttribute,
                                                                               multiplier: 1,
                                                                               constant: 40)
            
            textField.text = self.itemArray[sender.tag].name
            textField.placeholder = "名稱"
            textField.font = .systemFont(ofSize: 16)
            textField.addConstraint(oneLineTextFieldHieght)
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            
            let oneLineTextFieldHieght:NSLayoutConstraint = NSLayoutConstraint(item: textField,
                                                                               attribute: .height,
                                                                               relatedBy: .equal,
                                                                               toItem: nil,
                                                                               attribute: .notAnAttribute,
                                                                               multiplier: 1,
                                                                               constant: 40)
            
            textField.text = self.itemArray[sender.tag].price
            textField.placeholder = "價格"
            textField.font = .systemFont(ofSize: 16)
            textField.addConstraint(oneLineTextFieldHieght)
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            
            let oneLineTextFieldHieght:NSLayoutConstraint = NSLayoutConstraint(item: textField,
                                                                               attribute: .height,
                                                                               relatedBy: .equal,
                                                                               toItem: nil,
                                                                               attribute: .notAnAttribute,
                                                                               multiplier: 1,
                                                                               constant: 40)
            
            textField.text = self.itemArray[sender.tag].description
            textField.addConstraint(oneLineTextFieldHieght)
            textField.font = .systemFont(ofSize: 16)
            textField.placeholder = "描述"
        }
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[登入]按鈕
        let okAction = UIAlertAction(
            title: "修正",
            style: UIAlertAction.Style.default) {
                (action: UIAlertAction!) -> Void in
                let editName =
                    (alertController.textFields?[0])!
                        as UITextField
                let editPrice =
                    (alertController.textFields?[1])!
                        as UITextField
                let editDescription =
                    (alertController.textFields?[2])!
                        as UITextField
                var updateServiceInfo : [String : AnyObject] = [String : AnyObject]()
                updateServiceInfo["name"] = editName.text as AnyObject
                updateServiceInfo["price"] = editPrice.text as AnyObject
                updateServiceInfo["description"] = editDescription.text as AnyObject
         
                if self.typeSegFlag == 0{
                    self.ref.child("service").child(self.itemArray[sender.tag].key).updateChildValues(updateServiceInfo)
                    
                    let refService : DatabaseReference! = Database.database().reference().child("service")
                    self.serviceArray = []
                    refService.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                        var serviceItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
                        if let dictionaryData = snapshot.value as? [String:AnyObject]{
                            for item in dictionaryData{
                                serviceItem.key = snapshot.key
                                switch item.key {
                                case "name":
                                    serviceItem.name = item.value as! String
                                case "price":
                                    serviceItem.price = item.value as! String
                                case "description":
                                    serviceItem.description = item.value as! String
                                default:
                                    break
                                }
                            }
                            self.serviceArray.append(serviceItem)
                            //print(self.serviceArray)
                        }
                        self.itemArray = self.serviceArray
                        self.aTableView.reloadData()
                    })
                }
                else if self.typeSegFlag == 2{
                    self.ref.child("addPerchase").child(self.itemArray[sender.tag].key).updateChildValues(updateServiceInfo)
                    
                    let refAddPerchase : DatabaseReference! = Database.database().reference().child("addPerchase")
                    self.addPerchaseArray = []
                    refAddPerchase.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
                        var addPerchaseItem : item = item(key: "", name: "", price: "", description: "", imagePath: "")
                        if let dictionaryData = snapshot.value as? [String:AnyObject]{
                            for item in dictionaryData{
                                addPerchaseItem.key = snapshot.key
                                switch item.key {
                                case "name":
                                    addPerchaseItem.name = item.value as! String
                                case "price":
                                    addPerchaseItem.price = item.value as! String
                                case "description":
                                    addPerchaseItem.description = item.value as! String
                                default:
                                    break
                                }
                            }
                            self.addPerchaseArray.append(addPerchaseItem)
                            //print(self.serviceArray)
                        }
                        self.itemArray = self.addPerchaseArray
                        self.aTableView.reloadData()
                    })
                }
                
                
        }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(
            alertController,
            animated: true,
            completion: nil)
    */}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tag = sender as! Int
        let controller = segue.destination as! EditViewController
        var type = String()
        switch typeSegFlag {
        case 0:
            type = "服務產品"
        case 1:
            type = "美容師"
        case 2:
            type = "加購產品"
        default:
            type = "Error"
        }
        controller.carryInfo.type = type
        controller.carryInfo.name = self.itemArray[tag].name
        controller.carryInfo.price = self.itemArray[tag].price
        controller.carryInfo.Description = self.itemArray[tag].description
        controller.carryInfo.Image = self.itemArray[tag].imagePath
    }
}
