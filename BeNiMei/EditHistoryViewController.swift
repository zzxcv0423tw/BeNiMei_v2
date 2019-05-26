//
//  EditHistoryViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/5/26.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class EditHistoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var customerNameTF : UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerPhoneTF : UITextField!
    @IBOutlet weak var dateButton : UIButton!
    @IBOutlet weak var serviceTV : UITextView!
    @IBOutlet weak var priceTF : UITextField!
    @IBOutlet weak var beauticianButton : UIButton!
    @IBOutlet weak var paymentSwitch : UISwitch!
    @IBOutlet weak var photoImageView : UIImageView!
    @IBOutlet weak var darkBackgroundImageView: UIImageView!
    
    struct cuInfo {
        var key = String()
        var name = String()
        var phone = String()
        var date = String()
        var service = String()
        var price = String()
        var beautician = String()
        var payment = String()
        var imagePath = String()
    }
    
    var pickerSelectedBeautician = String()
    var beauticians = [String]()
    var hasImageFlag = 0
    var carryInfo = cuInfo()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "編輯歷史紀錄"
        self.hideKeyboardWhenTappedAround()

        titleLabel.text = carryInfo.name + " 的歷史紀錄"
        customerNameTF.text = carryInfo.name
        customerPhoneTF.text = carryInfo.phone
        dateButton.setTitle(carryInfo.date, for: .normal)
        serviceTV.text = carryInfo.service
        priceTF.text = carryInfo.price
        beauticianButton.setTitle(carryInfo.beautician, for: .normal)
        if carryInfo.payment == "cash" {
            paymentSwitch.setOn(false, animated: false)
        }else{
            paymentSwitch.setOn(true, animated: false)
        }
        
        let refImage = Storage.storage().reference().child("image/\(self.carryInfo.imagePath)")
        refImage.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error{
                print(error)
            }
            else {
                self.photoImageView.image = UIImage(data: data!)
            }
        }
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImage)))
        
        let refBeautician  = Database.database().reference().child("beautician")
        refBeautician.queryOrderedByKey().observe(.childAdded) { (snapshot) in
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
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            customerNameTF.font = UIFont.systemFont(ofSize: 27)
            customerPhoneTF.font = UIFont.systemFont(ofSize: 27)
            dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 27)
            serviceTV.font = UIFont.systemFont(ofSize: 27)
            priceTF.font = UIFont.systemFont(ofSize: 27)
            beauticianButton.titleLabel?.font = UIFont.systemFont(ofSize: 27)
            titleLabel.font = UIFont.systemFont(ofSize: 27)
        }
        
        
        
    }
    @IBAction func changeImage(_ sender: Any){
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFormPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFormPicker = editedImage
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFormPicker = originalImage
        }
        if let selectedImage = selectedImageFormPicker {
            photoImageView.image = selectedImage
            hasImageFlag = 1
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func timeSelection(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        datePicker.locale = Locale(identifier: "zh_TW")
        vc.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "請選擇時間", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let dateObj = dateFormatter.string(from: datePicker.date)
            self.dateButton.setTitle(dateObj, for: .normal)
            let formatter = DateFormatter()
            formatter.dateFormat = "yy/MM/dd HH:mm"
            formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
            let datePicked : NSDate = formatter.date(from: self.dateButton.currentTitle ?? "0") as! NSDate
        }))
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = dateButton
                currentPopoverpresentioncontroller.sourceRect = dateButton.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func beauticianSelection(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250, height: 300)
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        picker.delegate = self
        picker.dataSource = self
        
        vc.view.addSubview(picker)
        picker.selectRow(beauticians.count/2, inComponent: 0, animated: false)
        let alert = UIAlertController(title: "請選擇美容師", message: nil, preferredStyle: .alert)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            self.beauticianButton.setTitle(self.pickerSelectedBeautician, for: .normal)
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
        pickerSelectedBeautician = beauticians[row]
        return beauticians[row % beauticians.count]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelectedBeautician = beauticians[row]
    }
    @IBAction func submit(_ sender: Any) {
        let alert = UIAlertController(title: "確認", message: "確定修改歷史紀錄？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { (action) in
            if self.hasImageFlag == 1 {
                let checkPrice = self.priceTF.text
                if (checkPrice?.isInt)! {
                    self.darkBackgroundImageView.layer.zPosition = 4
                    self.darkBackgroundImageView.isHighlighted = false
                    self.activityIndicator.layer.zPosition = 5
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    
                    let storageRef = Storage.storage().reference().child("image").child(self.carryInfo.imagePath)
                    if let uploadData = self.photoImageView.image!.pngData() {
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, pError) in
                            if pError != nil {
                                print(pError as Any)
                                return
                            }
                            storageRef.downloadURL(completion: { (url, error) in
                                if let error = error {
                                    print(errSSLProtocol)
                                }
                                else {
                                    var itemInfo : [String : AnyObject] = [String : AnyObject]()
                                    itemInfo["name"] = self.customerNameTF.text as AnyObject
                                    itemInfo["phone"] = self.customerPhoneTF.text as AnyObject
                                    itemInfo["date"] = self.dateButton.currentTitle as AnyObject
                                    //itemInfo[]
                                    itemInfo["price"] = self.priceTF.text as AnyObject
                                    itemInfo["beautician"] = self.beauticianButton.currentTitle as AnyObject
                                    if self.paymentSwitch.isOn{
                                        itemInfo["payment"] = "transfer" as AnyObject
                                    }
                                    else {
                                        itemInfo["payment"] = "cash" as AnyObject
                                    }
                                    var serviceArray : [String.SubSequence] = []
                                    if self.serviceTV.text.contains("\r\n") {
                                        serviceArray = self.serviceTV.text.split(separator: "\r\n")
                                    } else {
                                        serviceArray = self.serviceTV.text.split(separator: "\n")
                                    }
                                    var itemServiceInfo : [String : AnyObject] = [String : AnyObject]()
                                    var index = 0
                                    for eachService in serviceArray {
                                        itemServiceInfo[String(index)] = eachService as AnyObject
                                        index = index + 1
                                    }
                                    Database.database().reference().child("customer").child(self.carryInfo.key).child("service").removeValue()
                                    let itemServiceInfoRef = Database.database().reference().child("customer").child(self.carryInfo.key).child("service")
                                    let serviceInfoRef = Database.database().reference().child("customer").child(itemServiceInfoRef.key ?? "000")
                                    itemServiceInfoRef.updateChildValues(itemServiceInfo){(err,reff) in
                                        if err != nil{
                                            print("err: \(err!)")
                                            return
                                        }
                                    }
                                    
                                    
                                    
                                    
                                    let childRef = Database.database().reference().child("customer").child(self.carryInfo.key)
                                    let serviceInfoReference = Database.database().reference().child("customer").child(childRef.key ?? "000")
                                    
                                    serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                                        if err != nil{
                                            print("err: \(err!)")
                                            return
                                        }
                                        //print(reff.description())
                                    }
                                    
                                }
                                self.activityIndicator.startAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.darkBackgroundImageView.isHidden = true
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    }
                }
                else {
                    let denySubmitAlert = UIAlertController(title: "錯誤", message: "價格欄位必須為數字！", preferredStyle: .alert)
                    denySubmitAlert.addAction(UIAlertAction(title: "確認", style: .cancel, handler: nil))
                    self.present(denySubmitAlert, animated: true, completion: nil)
                }
            }
            else {
                
                let checkPrice = self.priceTF.text
                if (checkPrice?.isInt)! {
                    self.darkBackgroundImageView.layer.zPosition = 4
                    self.darkBackgroundImageView.isHidden = false
                    self.activityIndicator.layer.zPosition = 5
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    
                    var itemInfo : [String : AnyObject] = [String : AnyObject]()
                    itemInfo["name"] = self.customerNameTF.text as AnyObject
                    itemInfo["phone"] = self.customerPhoneTF.text as AnyObject
                    itemInfo["date"] = self.dateButton.currentTitle as AnyObject
                    //itemInfo[]
                    itemInfo["price"] = self.priceTF.text as AnyObject
                    itemInfo["beautician"] = self.beauticianButton.currentTitle as AnyObject
                    if self.paymentSwitch.isOn{
                        itemInfo["payment"] = "transfer" as AnyObject
                    }
                    else {
                        itemInfo["payment"] = "cash" as AnyObject
                    }
                    
                    let serviceArray = self.serviceTV.text.split(separator: "\n")
                    var itemServiceInfo : [String : AnyObject] = [String : AnyObject]()
                    var index = 0
                    for eachService in serviceArray {
                        itemServiceInfo[String(index)] = eachService as AnyObject
                        index = index + 1
                    }
                    Database.database().reference().child("customer").child(self.carryInfo.key).child("service").removeValue()
                    let itemServiceInfoRef = Database.database().reference().child("customer").child(self.carryInfo.key).child("service")
                    let serviceInfoRef = Database.database().reference().child("customer").child(itemServiceInfoRef.key ?? "000")
                    itemServiceInfoRef.updateChildValues(itemServiceInfo){(err,reff) in
                        if err != nil{
                            print("err: \(err!)")
                            return
                        }
                    }
                    
                    
                    
                    
                    let childRef = Database.database().reference().child("customer").child(self.carryInfo.key)
                    let serviceInfoReference = Database.database().reference().child("customer").child(childRef.key ?? "000")
                    
                    serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                        if err != nil{
                            print("err: \(err!)")
                            return
                        }
                        //print(reff.description())
                    }
                    self.activityIndicator.stopAnimating()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.darkBackgroundImageView.isHidden = true
                    self.navigationController?.popViewController(animated: true)
                }
                else {
                    let denySubmitAlert = UIAlertController(title: "錯誤", message: "價格欄位必須為數字！", preferredStyle: .alert)
                    denySubmitAlert.addAction(UIAlertAction(title: "確認", style: .cancel, handler: nil))
                    self.present(denySubmitAlert, animated: true, completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
