//
//  AddItemViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/25/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    var addTypeflag: Int8  = 0
    var hasImageFlag: Int8 = 0
    
    @IBOutlet weak var addItemName: UITextField!
    @IBOutlet weak var addServicePrice: UITextField!
    @IBOutlet weak var addServiceDescription: UITextView!
    @IBOutlet weak var addServiceImageView: UIImageView!
    @IBOutlet weak var darkBackgroundImageView: UIImageView!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    var ref: DatabaseReference! = Database.database().reference()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新增項目"
        self.hideKeyboardWhenTappedAround() 
        addServiceImageView.isUserInteractionEnabled = true
        addServiceImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addServiceImage)))
        
        addServiceDescription.delegate = self
        Auth.auth().currentUser
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            addItemName.font = UIFont.systemFont(ofSize: 27)
            addServicePrice.font = UIFont.systemFont(ofSize: 27)
            addServiceDescription.font = UIFont.systemFont(ofSize: 27)
            typeSegmentedControl.setTitleTextAttributes([.font:UIFont.systemFont(ofSize: 23)], for: .normal)
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mySegSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex==0{
            addTypeflag = 0
            addServicePrice.isHidden = false
            addServiceDescription.isHidden = false
        }
        else if sender.selectedSegmentIndex==1{
            addTypeflag = 1
            addServicePrice.isHidden = true
            addServiceDescription.isHidden = true
        }
        else if sender.selectedSegmentIndex==2{
            addTypeflag = 2
            addServicePrice.isHidden = false
            addServiceDescription.isHidden = false
        }
    }
    
    @IBAction func addServiceImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        //picker.allowsEditing = true
        
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
            addServiceImageView.image = selectedImage
            hasImageFlag = 1
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func alert(_ sender: Any) {
        
        let uniqueString = NSUUID().uuidString
        
        if addTypeflag == 0 {
            let alert = UIAlertController(title: "確認", message: "確定新增服務項目？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
                if self.hasImageFlag == 0 {
                    self.addServiceImageView.image = UIImage(named: "noun_Lost_file")
                }
                let checkPrice = self.addServicePrice.text
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
                    var imageUrl : String = String()
                    
                    let storageRef = Storage.storage().reference().child("image").child("ser_\(uniqueString).png")
                    if let uploadData = self.addServiceImageView.image!.pngData() {
                        
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, pError) in
                            if pError != nil{
                                print(pError as Any)
                                return
                            }
                            storageRef.downloadURL(completion: { (url, error) in
                                if let error = error{
                                    print(error)
                                }
                                else {
                                    imageUrl = url?.absoluteString ?? "000"
                                    
                                    var serviceInfo : [String : AnyObject] = [String : AnyObject]()
                                    serviceInfo["name"] = self.addItemName.text as AnyObject
                                    serviceInfo["price"] = self.addServicePrice.text as AnyObject
                                    serviceInfo["description"] = self.addServiceDescription.text as AnyObject
                                    serviceInfo["imageUrl"] = imageUrl as AnyObject
                                    serviceInfo["imagePath"] = ("ser_\(uniqueString).png") as AnyObject
                                    
                                    let childRef = self.ref.child("service").childByAutoId()
                                    let serviceInfoReference = self.ref.child("service").child(childRef.key ?? "000")
                                    
                                    serviceInfoReference.updateChildValues(serviceInfo){(err,reff) in
                                        if err != nil{
                                            print("err: \(err!)")
                                            return
                                        }
                                        //print(reff.description())
                                    }
                                }
                                self.activityIndicator.stopAnimating()
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
            ))
            self.present(alert, animated: true, completion: nil)
        }
        else if addTypeflag == 1{
            let alert = UIAlertController(title: "確認", message: "確定新增美容師？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
                
                    if self.hasImageFlag == 0 {
                        self.addServiceImageView.image = UIImage(named: "noun_Lost_file")
                    }
                    self.darkBackgroundImageView.layer.zPosition = 4
                    self.darkBackgroundImageView.isHidden = false
                    self.activityIndicator.layer.zPosition = 5
                    self.activityIndicator.center = self.view.center
                    self.activityIndicator.hidesWhenStopped = true
                    self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                    self.view.addSubview(self.activityIndicator)
                    self.activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    var imageUrl : String = String()
                    
                    let storageRef = Storage.storage().reference().child("image").child("bea_\(uniqueString).png")
                    if let uploadData = self.addServiceImageView.image!.pngData(){
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil{
                                print(error)
                                return
                            }
                            storageRef.downloadURL(completion: { (url, error) in
                                if let error = error {
                                    print(error)
                                    return
                                }
                                else {
                                    imageUrl = url?.absoluteString ?? "000"
                                    var beauticianInfo : [String : AnyObject] = [String : AnyObject]()
                                    beauticianInfo["name"] = self.addItemName.text as AnyObject
                                    beauticianInfo["imagePath"] = ("bea_\(uniqueString).png") as AnyObject
                                    
                                    let childRef = self.ref.child("beautician").childByAutoId()
                                    let beauticianInfoReference = self.ref.child("beautician").child(childRef.key ?? "000")
                                    
                                    beauticianInfoReference.updateChildValues(beauticianInfo){(err,reff) in
                                        if err != nil{
                                            print("err: \(err!)")
                                            return
                                        }
                                        //print(reff.description())
                                    }
                                }
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.darkBackgroundImageView.isHidden = true
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    }
            }
            ))
            self.present(alert, animated: true, completion: nil)
            
        }
        else if addTypeflag == 2 {
            
            let alert = UIAlertController(title: "確認", message: "確定新增加購產品？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
                
                if self.hasImageFlag == 0 {
                    self.addServiceImageView.image = UIImage(named: "noun_Lost_file")
                }
                let checkPrice = self.addServicePrice.text
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
                var imageUrl : String = String()
            
            
            let storageRef = Storage.storage().reference().child("image").child("ape_\(uniqueString).png")
            if let uploadData = self.addServiceImageView.image!.pngData() {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error{
                            print(error)
                        }
                        else {
                            imageUrl = url?.absoluteString ?? "000"
                            
                            var addPerchaseInfo : [String : AnyObject] = [String : AnyObject]()
                            addPerchaseInfo["name"] = self.addItemName.text as AnyObject
                            addPerchaseInfo["price"] = self.addServicePrice.text as AnyObject
                            addPerchaseInfo["description"] = self.addServiceDescription.text as AnyObject
                            addPerchaseInfo["imageUrl"] = imageUrl as AnyObject
                            addPerchaseInfo["imagePath"] = ("ape_\(uniqueString).png") as AnyObject
                            
                            let childRef = self.ref.child("addPerchase").childByAutoId()
                            let serviceInfoReference = self.ref.child("addPerchase").child(childRef.key ?? "000")
                            
                            serviceInfoReference.updateChildValues(addPerchaseInfo){(err,reff) in
                                if err != nil{
                                    print("err: \(err!)")
                                    return
                                }
                                print(reff.description())
                            }
                        }
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.darkBackgroundImageView.isHidden = true
                        self.navigationController?.popViewController(animated: true)
                    })
                })
            }
    }
    else{
        let denyAlert = UIAlertController(title: "錯誤", message: "價格欄位必須為數字！", preferredStyle: .alert)
        denyAlert.addAction(UIAlertAction(title: "確認", style: .cancel, handler: nil))
        self.present(denyAlert, animated: true, completion: nil)
                }       
        }
        ))
        self.present(alert, animated: true, completion: nil)
        }
        
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "描述簡介"{
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "描述簡介"
        }
    }
}
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
