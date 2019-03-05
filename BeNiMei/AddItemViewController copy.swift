//
//  AddItemViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/25/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var addTypeflag: Bool = true
    @IBOutlet weak var addItemName: UITextField!
    @IBOutlet weak var addServicePrice: UITextField!
    @IBOutlet weak var addServiceDescription: UITextView!
    @IBOutlet weak var addServiceImage: UIImageView!
    @IBOutlet weak var a: UIImageView!
    @IBOutlet weak var a: UIImageView!
    @IBOutlet weak var addServiceImage: UIImageView!
    
    var ref: DatabaseReference! = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "新增項目"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mySegSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex==0{
            addTypeflag = true
            addServicePrice.isHidden = false
            addServiceDescription.isHidden = false
        }
        else if sender.selectedSegmentIndex==1{
            addTypeflag = false
            addServicePrice.isHidden = true
            addServiceDescription.isHidden = true
        }
    }
    
    @IBAction func addServiceImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    @IBAction func alert(_ sender: Any) {
        if addTypeflag == true {
            let alert = UIAlertController(title: "確認", message: "確定新增服務項目？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
                
                var serviceInfo : [String : AnyObject] = [String : AnyObject]()
                serviceInfo["name"] = self.addItemName.text as AnyObject
                serviceInfo["price"] = self.addServicePrice.text as AnyObject
                serviceInfo["description"] = self.addServiceDescription.text as AnyObject
                
                let childRef = self.ref.child("service").childByAutoId()
                let serviceInfoReference = self.ref.child("service").child(childRef.key ?? "000")
                
                serviceInfoReference.updateChildValues(serviceInfo){(err,reff) in
                    if err != nil{
                        print("err: \(err!)")
                        return
                    }
                    print(reff.description())
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            ))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "確認", message: "確定新增美容師？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
                
                
                var beauticianInfo : [String : AnyObject] = [String : AnyObject]()
                beauticianInfo["name"] = self.addItemName.text as AnyObject
                
                let childRef = self.ref.child("beautician").childByAutoId()
                let beauticianInfoReference = self.ref.child("beautician").child(childRef.key ?? "000")
                
                beauticianInfoReference.updateChildValues(beauticianInfo){(err,reff) in
                    if err != nil{
                        print("err: \(err!)")
                        return
                    }
                    print(reff.description())
                }
                /*************
                 *傳送美容師資料*
                 *************/
                
                self.navigationController?.popViewController(animated: true)
            }
            ))
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

}
