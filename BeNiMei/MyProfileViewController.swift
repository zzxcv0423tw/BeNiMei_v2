//
//  MyProfileViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/4/8.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase
class MyProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1.5
        profileImageView.layer.borderColor = UIColor(displayP3Red: 0.49, green: 0.372, blue: 0.275, alpha: 1).cgColor
        let navBackgroundImage = UIImage(named: "topbar_1200_120")
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
        profileEmailLabel.text = Auth.auth().currentUser?.email
        if Auth.auth().currentUser?.email != "admin@admin.com"{
            profileImageView.image = UIImage(named: "user")
        }
        else {
            profileImageView.image = UIImage(named: "ManagerUser")
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
    
}
