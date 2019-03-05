//
//  SecondViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/6/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController  {

    @IBOutlet weak var aSlider: UISlider!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var reasonTextView: UITextView!
    @IBOutlet weak var suggetTextView: UITextView!
    @IBOutlet weak var dataLabel: UILabel!
    
    
    @IBAction func aSliderChange(_ sender: Any) {
         scoreLabel.text = String(Int(aSlider.value))
    }
    @IBAction func alert(_ sender: Any) {
        let alert = UIAlertController(title: "確認", message: "確定送出？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { action in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let currentDate = dateFormatter.string(from: Date())
            var satusfactionArray : [String : AnyObject] = [String:AnyObject]()
            satusfactionArray["score"] = self.scoreLabel.text as AnyObject
            satusfactionArray["reason"] = self.reasonTextView.text as AnyObject
            satusfactionArray["suggest"] = self.suggetTextView.text as AnyObject
            satusfactionArray["date"] = currentDate as AnyObject
            
            let refWriteDBFild : DatabaseReference! = Database.database().reference().child("satisfaction")
            let childRef = refWriteDBFild.childByAutoId()
            let satisfactionReference = refWriteDBFild.child(childRef.key ?? "000")
            
            satisfactionReference.updateChildValues(satusfactionArray){
                (err ,reff) in
                if err != nil{
                    print("err: \(err!)")
                    return
                }
                
                print(reff.description())
            }
            
            
            
            self.reasonTextView.text = "原因"
            self.suggetTextView.text = "建議"
            self.aSlider.value = 60
            self.scoreLabel.text = "60"
            
            /*************
             *傳送滿意度資料*
             *************/
            
            //回到根目錄
            //self.navigationController?.popToRootViewController(animated: true)
        }
        ))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataLabel.backgroundColor =     UIColor(patternImage: UIImage(named: "bg_150_200")!)
        // Do any additional setup after loading the view, typically from a nib.
        let navBackgroundImage = UIImage(named: "topbar_500_120")
       scoreLabel.text = String(Int(aSlider.value))
        
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
        
        
        self.hideKeyboardWhenTappedAround() 
    }

}

