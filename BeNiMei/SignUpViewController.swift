//
//  SignUpViewController.swift
//  BeNiMei
//
//  Created by user149927 on 3/1/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            signUpLabel.font = UIFont.systemFont(ofSize: 60)
            nameTextField.font = UIFont.systemFont(ofSize: 30)
            emailTextField.font = UIFont.systemFont(ofSize: 30)
            passwordTextField.font = UIFont.systemFont(ofSize: 30)
            SignUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        }
        self.hideKeyboardWhenTappedAround() 
        
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            let alertController = UIAlertController(title: "錯誤", message: "請確認電子信箱和密碼皆有填入", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        else if nameTextField.text == ""{
            let alertController = UIAlertController(title: "錯誤", message: "請確認美容師名稱有填入", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
        else {
            
            //寫入FireBase Auth
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully signed up")
                    //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                    let uniqueString = NSUUID().uuidString
                    var image = UIImage(named: "ManagerUser")
                    let storageRef = Storage.storage().reference().child("image").child("bea_\(uniqueString).png")
                    if let uploadData = image?.pngData(){
                        storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
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
                                    
                                    
                                    //寫入Firebase DataBase
                                    var authInfo : [String : AnyObject] = [String : AnyObject]()
                                    authInfo["name"] = self.nameTextField.text as AnyObject
                                    authInfo["email"] = self.emailTextField.text?.lowercased() as AnyObject
                                    authInfo["imagePath"] = ("bea_\(uniqueString).png") as AnyObject
                                    let ref: DatabaseReference! = Database.database().reference().child("beautician")
                                    let childRef = ref.childByAutoId()
                                    let authReference = ref.child(childRef.key ?? "000")
                                    
                                    authReference.updateChildValues(authInfo){ (err, reff) in
                                        if err != nil{
                                            print("err: \(err)")
                                            return
                                        }
                                    }
                                    
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "login")
                                    self.present(vc!, animated: true, completion: nil)
                                }
                            })
                        })
                    }
                    
                    
                    
                    
                } else {
                    let alertController = UIAlertController(title: "錯誤", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction func pop(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "login")
        self.present(vc!, animated: true, completion: nil)
        
        
    }
}
