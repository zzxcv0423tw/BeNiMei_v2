//
//  EditViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/4/8.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var ItemTypeLabel: UILabel!
    @IBOutlet weak var ItemNameTextField: UITextField!
    @IBOutlet weak var ItemPriceTextField: UITextField!
    @IBOutlet weak var ItemDescriptionTextView: UITextView!
    @IBOutlet weak var ItemPhotoImageView: UIImageView!
    @IBOutlet weak var DarkBackgroundImageView: UIImageView!
    
    struct info {
        var key = String()
        var type = String()
        var name = String()
        var price = String()
        var Description = String()
        var Image = String()
    }
    
    var hasImageFlag: Int8 = 0
    var carryInfo = info()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "編輯項目"
        self.hideKeyboardWhenTappedAround()
        
        var type = String()
        switch carryInfo.type {
        case "0":
            type = "服務產品"
            ItemPriceTextField.isHidden = false
            ItemDescriptionTextView.isHidden = false
        case "1":
            type = "美容師"
            ItemPriceTextField.isHidden = true
            ItemDescriptionTextView.isHidden = true
        case "2":
            type = "加購產品"
            ItemPriceTextField.isHidden = false
            ItemDescriptionTextView.isHidden = false
        default:
            type = "Error"
            ItemPriceTextField.isHidden = false
            ItemDescriptionTextView.isHidden = false
        }
        ItemTypeLabel.text = type
        ItemNameTextField.text = carryInfo.name
        ItemPriceTextField.text = carryInfo.price
        ItemDescriptionTextView.text = carryInfo.Description
        
        let pathRef = Storage.storage().reference().child("image/\(self.carryInfo.Image)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error {
                print(error)
            }
            else {
                self.ItemPhotoImageView.image = UIImage(data: data!)
            }
        }
        
        ItemPhotoImageView.isUserInteractionEnabled = true
        ItemPhotoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImage)))
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
            ItemPhotoImageView.image = selectedImage
            hasImageFlag = 1
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func alert(_ sender: Any) {
        if carryInfo.type == "0"{
            let alert = UIAlertController(title: "確認", message: "確定修改服務項目？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { (action) in
                if self.hasImageFlag == 1 {
                    let checkPrice = self.ItemPriceTextField.text
                    if (checkPrice?.isInt)! {
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        let storageRef = Storage.storage().reference().child("image").child(self.carryInfo.Image)
                        if let uploadData = self.ItemPhotoImageView.image!.pngData(){
                            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, pError) in
                                if pError != nil {
                                    print(pError as Any)
                                    return
                                }
                                storageRef.downloadURL(completion: { (url, error) in
                                    if let error = error{
                                        print(error)
                                    }
                                    else {
                                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                                        itemInfo["price"] = self.ItemPriceTextField.text as AnyObject
                                        itemInfo["description"] = self.ItemDescriptionTextView.text as AnyObject
                                        
                                        let childRef = Database.database().reference().child("service").child(self.carryInfo.key)
                                        let serviceInfoReference = Database.database().reference().child("service").child(childRef.key ?? "000")
                                        
                                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                                            if err != nil{
                                                print("err: \(err!)")
                                                return
                                            }
                                            print(reff.description())
                                        }
                                    }
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.DarkBackgroundImageView.isHidden = true
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
                    
                    let checkPrice = self.ItemPriceTextField.text
                    if (checkPrice?.isInt)! {
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                        itemInfo["price"] = self.ItemPriceTextField.text as AnyObject
                        itemInfo["description"] = self.ItemDescriptionTextView.text as AnyObject
                        
                        let childRef = Database.database().reference().child("service").child(self.carryInfo.key)
                        let serviceInfoReference = Database.database().reference().child("service").child(childRef.key ?? "000")
                        
                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                            if err != nil{
                                print("err: \(err!)")
                                return
                            }
                            print(reff.description())
                        }
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.DarkBackgroundImageView.isHidden = true
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
        else if carryInfo.type == "1"{
            let alert = UIAlertController(title: "確認", message: "確定修改美容師？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { (action) in
                if self.hasImageFlag == 1 {
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        let storageRef = Storage.storage().reference().child("image").child(self.carryInfo.Image)
                        if let uploadData = self.ItemPhotoImageView.image!.pngData(){
                            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, pError) in
                                if pError != nil {
                                    print(pError as Any)
                                    return
                                }
                                storageRef.downloadURL(completion: { (url, error) in
                                    if let error = error{
                                        print(error)
                                    }
                                    else {
                                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                                        
                                        let childRef = Database.database().reference().child("beautician").child(self.carryInfo.key)
                                        let serviceInfoReference = Database.database().reference().child("beautician").child(childRef.key ?? "000")
                                        
                                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                                            if err != nil{
                                                print("err: \(err!)")
                                                return
                                            }
                                            print(reff.description())
                                        }
                                    }
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.DarkBackgroundImageView.isHidden = true
                                    self.navigationController?.popViewController(animated: true)
                                })
                            })
                        }
                }
                else {
                    
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                        
                        let childRef = Database.database().reference().child("beautician").child(self.carryInfo.key)
                        let serviceInfoReference = Database.database().reference().child("beautician").child(childRef.key ?? "000")
                        
                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                            if err != nil{
                                print("err: \(err!)")
                                return
                            }
                            print(reff.description())
                        }
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.DarkBackgroundImageView.isHidden = true
                        self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else if carryInfo.type == "2"{
            let alert = UIAlertController(title: "確認", message: "確定修改加購產品？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { (action) in
                if self.hasImageFlag == 1 {
                    let checkPrice = self.ItemPriceTextField.text
                    if (checkPrice?.isInt)! {
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        
                        let storageRef = Storage.storage().reference().child("image").child(self.carryInfo.Image)
                        if let uploadData = self.ItemPhotoImageView.image!.pngData(){
                            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, pError) in
                                if pError != nil {
                                    print(pError as Any)
                                    return
                                }
                                storageRef.downloadURL(completion: { (url, error) in
                                    if let error = error{
                                        print(error)
                                    }
                                    else {
                                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                                        itemInfo["price"] = self.ItemPriceTextField.text as AnyObject
                                        itemInfo["description"] = self.ItemDescriptionTextView.text as AnyObject
                                        
                                        let childRef = Database.database().reference().child("addPerchase").child(self.carryInfo.key)
                                        let serviceInfoReference = Database.database().reference().child("addPerchase").child(childRef.key ?? "000")
                                        
                                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                                            if err != nil{
                                                print("err: \(err!)")
                                                return
                                            }
                                            print(reff.description())
                                        }
                                    }
                                    self.activityIndicator.stopAnimating()
                                    UIApplication.shared.endIgnoringInteractionEvents()
                                    self.DarkBackgroundImageView.isHidden = true
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
                    
                    let checkPrice = self.ItemPriceTextField.text
                    if (checkPrice?.isInt)! {
                        self.DarkBackgroundImageView.layer.zPosition = 4
                        self.DarkBackgroundImageView.isHidden = false
                        self.activityIndicator.layer.zPosition = 5
                        self.activityIndicator.center = self.view.center
                        self.activityIndicator.hidesWhenStopped = true
                        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                        self.view.addSubview(self.activityIndicator)
                        self.activityIndicator.startAnimating()
                        UIApplication.shared.beginIgnoringInteractionEvents()
                        var itemInfo : [String : AnyObject] = [String : AnyObject]()
                        itemInfo["name"] = self.ItemNameTextField.text as AnyObject
                        itemInfo["price"] = self.ItemPriceTextField.text as AnyObject
                        itemInfo["description"] = self.ItemDescriptionTextView.text as AnyObject
                        
                        let childRef = Database.database().reference().child("addPerchase").child(self.carryInfo.key)
                        let serviceInfoReference = Database.database().reference().child("addPerchase").child(childRef.key ?? "000")
                        
                        serviceInfoReference.updateChildValues(itemInfo){(err,reff) in
                            if err != nil{
                                print("err: \(err!)")
                                return
                            }
                            print(reff.description())
                        }
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.DarkBackgroundImageView.isHidden = true
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
}
