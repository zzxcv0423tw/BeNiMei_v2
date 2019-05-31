//
//  MyProfileViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/4/8.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase
class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    struct beauticianInfo {
        var key = String()
        var name = String()
        var email = String()
        var imagePath = String()
    }
    
    var currentBeautician = beauticianInfo()
    var beauticianInfos = [beauticianInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.email != "admin@admin.com"{
            let deleteAccountBotton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tapDeleteAccountButton))
            self.navigationItem.rightBarButtonItem = deleteAccountBotton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeBeauticianImage)))
        
        let navBackgroundImage = UIImage(named: "topbar_1200_120")
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            profileEmailLabel.font = UIFont.systemFont(ofSize: 27)
            profileNameLabel.font = UIFont.systemFont(ofSize: 27)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        let ref = Database.database().reference().child("beautician")
        beauticianInfos = []
        ref.queryOrderedByKey().observe(.childAdded) { (snapshot) in
            var beautician = beauticianInfo()
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                beautician.key = snapshot.key
                for item in dictionaryData{
                    switch item.key{
                    case "name":
                        beautician.name = item.value as! String
                    case "email":
                        beautician.email = item.value as! String
                    case "imagePath":
                        beautician.imagePath = item.value as! String
                    default:
                        break
                    }
                }
                self.beauticianInfos.append(beautician)
            }
            
            if Auth.auth().currentUser?.email != "admin@admin.com"{
                self.profileImageView.image = UIImage(named: "user")
            }
            else {
                self.profileImageView.image = UIImage(named: "ManagerUser")
            }
            print(self.beauticianInfos)
            for item in self.beauticianInfos {
                if (Auth.auth().currentUser?.email == item.email){
                    self.currentBeautician.key = item.key
                    self.currentBeautician.name = item.name
                    self.currentBeautician.email = item.email
                    self.currentBeautician.imagePath = item.imagePath
                    
                    self.profileNameLabel.text = self.currentBeautician.name
                    self.profileEmailLabel.text = self.currentBeautician.email
                    
                    let refImage = Storage.storage().reference().child("image/\(self.currentBeautician.imagePath)")
                    refImage.getData(maxSize: 1*5120*5120, completion: { (data, error) in
                        if let error = error{
                            print(error)
                        }
                        else {
                            self.profileImageView.image = UIImage(data:data!)
                        }
                    })
                }
            }
            
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do{
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
                present(vc, animated: true, completion: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    @IBAction func changeBeauticianImage(_ sender: Any){
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
            profileImageView.image = selectedImage
            let storageRef = Storage.storage().reference().child("image").child(self.currentBeautician.imagePath)
            if let uploadData = self.profileImageView.image!.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    }
                })
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion: nil)
    }
    @IBAction func tapDeleteAccountButton(_ sender: Any){
        let alert = UIAlertController(title: "刪除帳戶", message: "確定要刪除現在登入的帳號嗎？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (action) in
            var currentUser = Auth.auth().currentUser
            currentUser?.delete { error in
                if let error = error {
                    print(error)
                } else {
                    
                    let storageRef = Storage.storage().reference().child("image").child(self.currentBeautician.imagePath)
                    storageRef.delete(completion: { (error) in
                        if let error = error {
                            print(error)
                        }
                        else {
                            //delete successful !
                        }
                    })
                    
                    let dbRef = Database.database().reference().child("beautician").child(self.currentBeautician.key)
                    dbRef.removeValue()
                    
                    
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
                    self.present(vc, animated: true, completion: nil)
                }
                
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}
