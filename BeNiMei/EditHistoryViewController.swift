//
//  EditHistoryViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/5/26.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class EditHistoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var customerNameTF : UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerPhoneTF : UITextField!
    @IBOutlet weak var dateTF : UITextField!
    @IBOutlet weak var serviceTV : UITextView!
    @IBOutlet weak var priceTF : UITextField!
    @IBOutlet weak var beauticianTF : UITextField!
    @IBOutlet weak var paymentSwitch : UISwitch!
    @IBOutlet weak var photoImageView : UIImageView!
    
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
    
    var hasImageFlag = 0
    var carryInfo = cuInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "編輯歷史紀錄"
        self.hideKeyboardWhenTappedAround()

        customerNameTF.text = carryInfo.name
        customerPhoneTF.text = carryInfo.phone
        dateTF.text = carryInfo.date
        serviceTV.text = carryInfo.service
        priceTF.text = carryInfo.price
        beauticianTF.text = carryInfo.beautician
        if carryInfo.payment == "cash" {
            paymentSwitch.isOn = false
        }else{
            paymentSwitch.isOn = true
        }
        
        let pathRef = Storage.storage().reference().child("image/\(self.carryInfo.imagePath)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error{
                print(error)
            }
            else {
                self.photoImageView.image = UIImage(data: data!)
            }
        }
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeImage)))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            customerNameTF.font = UIFont.systemFont(ofSize: 27)
            customerPhoneTF.font = UIFont.systemFont(ofSize: 27)
            dateTF.font = UIFont.systemFont(ofSize: 27)
            serviceTV.font = UIFont.systemFont(ofSize: 27)
            priceTF.font = UIFont.systemFont(ofSize: 27)
            beauticianTF.font = UIFont.systemFont(ofSize: 27)
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

}
