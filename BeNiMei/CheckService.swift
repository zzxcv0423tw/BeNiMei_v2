//
//  CheckService.swift
//  BeNiMei
//
//  Created by user149927 on 1/11/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class CheckService: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var ATableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentSwitch: UISwitch!
    @IBOutlet weak var remarkTextView: UITextView!
    @IBOutlet weak var remarkImageView: UIImageView!
    
    var hasImageFlag : Int8 = 0
    
    var cuName: String = ""
    var cuPhone: String = ""
    var cuDate: String = ""
    var cuBeautician: String = ""
    var cuImageView: UIImageView = UIImageView()
    
    var ref: DatabaseReference! = Database.database().reference()
    var refWriteDBFild: DatabaseReference! = Database.database().reference().child("customer")
    
    var orderedNameArrayc = ["無"]
    var priceArrayc = [0]
    //submit前確認
    @IBAction func alert(_ sender: Any) {
        
        let uniqueString = NSUUID().uuidString
        let uniqueString2 = NSUUID().uuidString
        
        let alert = UIAlertController(title: "確認", message: "確定送出？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
            
            var imageUrl : String = String()
            var imageUrl2 : String = String()
            let storageRef = Storage.storage().reference().child("image").child("cu_\(uniqueString).png")
            let storageRef2 = Storage.storage().reference().child("image").child("cu_\(uniqueString2).png")
            if self.hasImageFlag == 0 {
                self.remarkImageView.image = UIImage(named: "noun_Lost_file")
            }
            if let uploadData = self.cuImageView.image!.pngData(){
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata , pError) in
                    if pError != nil{
                        print(pError as Any)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error{
                            print(error)
                        }
                        else{
                            if let uploadData2 = self.remarkImageView.image!.pngData(){
                                storageRef2.putData(uploadData2, metadata: nil, completion: {(metadata, lError) in
                                    if lError != nil {
                                        print(lError as Any)
                                        return
                                    }
                                    storageRef2.downloadURL(completion: { (url2, error2) in
                                        if let error2 = error2{
                                            print(error2)
                                        }
                                        else {
                                            imageUrl = url?.absoluteString ?? "000"
                                            imageUrl2 = url2?.absoluteString ?? "000"
                                            
                                            var customerInfo: [String : AnyObject] = [String : AnyObject]()
                                            customerInfo["name"] = self.cuName as AnyObject
                                            customerInfo["phone"] = self.cuPhone as AnyObject
                                            customerInfo["date"] = self.cuDate as AnyObject
                                            customerInfo["beautician"] = self.cuBeautician as AnyObject
                                            customerInfo["service"] = self.orderedNameArrayc as AnyObject
                                            customerInfo["price"] = self.totalPrice.text as AnyObject
                                            var priceArraycStr = self.priceArrayc.map { String($0) }
                                            customerInfo["eachPrice"] = priceArraycStr as AnyObject
                                            customerInfo["imageUrl"] = imageUrl as AnyObject
                                            customerInfo["imageUrl2"] = imageUrl2 as AnyObject
                                            customerInfo["imagePath"] = ("cu_\(uniqueString).png") as AnyObject
                                            customerInfo["imagePath2"] = ("cu_\(uniqueString2).png") as AnyObject
                                            if self.remarkTextView.text == "註記" {
                                                customerInfo["remark"] = "無" as AnyObject
                                            }
                                            else {
                                                customerInfo["remark"] = self.remarkTextView.text as AnyObject
                                            }
                                            if self.paymentSwitch.isOn {
                                                customerInfo["payment"] = "transfer" as AnyObject
                                            }
                                            else {
                                                customerInfo["payment"] = "cash" as AnyObject
                                            }
                                            
                                            
                                            let childRef = self.refWriteDBFild.childByAutoId() // 隨機生成的節點唯一識別碼，用來當儲存時的key值
                                            let customerInfoReference = self.refWriteDBFild.child(childRef.key ?? "000")
                                            
                                            customerInfoReference.updateChildValues(customerInfo) { (err, reff) in
                                                if err != nil{
                                                    print("err： \(err!)")
                                                    return
                                                }
                                                
                                                //print(reff.description())
                                            }
                                        }
                                    })
                                })
                            }
                            
                        }
                    })
                })
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
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            cell.serviceLabel.font = UIFont.systemFont(ofSize: 27)
            cell.priceLabel.font = UIFont.systemFont(ofSize: 27)
        }
        cell.serviceLabel.text = orderedNameArrayc[indexPath.row]
        cell.priceLabel.text = String( priceArrayc[indexPath.row])
        return cell
    }
    
    
    @IBOutlet weak var checkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        totalPrice.text = String(priceArrayc.reduce(0, +))
        
        ATableView.delegate = self
        ATableView.dataSource = self
        remarkTextView.delegate = self
        
        remarkImageView.isUserInteractionEnabled = true
        remarkImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(uploadRemarkImage)))
        
        checkLabel.backgroundColor =     UIColor(patternImage: UIImage(named: "bg_150_200")!)
        
        //print(cuName)
        //print(cuPhone)
        //print(cuBeautician)
        //print(cuDate)
        
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            totalLabel.font = UIFont.systemFont(ofSize: 28)
            totalPrice.font = UIFont.systemFont(ofSize: 45)
            remarkTextView.font = UIFont.systemFont(ofSize: 22)
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "註記" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 0 && textView.text == "" {
            textView.text = "註記"
        }
    }
    @IBAction func uploadRemarkImage(_ sender: Any){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFormPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFormPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage{
            selectedImageFormPicker = originalImage
        }
        
        if let selectedImage = selectedImageFormPicker{
            remarkImageView.image = selectedImage
            hasImageFlag = 1
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
