//
//  EditSatisfactionViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/5/27.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class EditSatisfactionViewController: UIViewController {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var scoreSlider : UISlider!
    @IBOutlet weak var reasonTextView : UITextView!
    @IBOutlet weak var suggestionTextView : UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    struct satisfaction {
        var key : String = String()
        var score : String = String()
        var reason : String = String()
        var suggest : String = String()
        var date : String = String()
    }
    
    var satisfactions = satisfaction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "編輯滿意度紀錄"
        
        scoreSlider.value = (Float(satisfactions.score) ?? 60.0) / 100.0
        reasonTextView.text = satisfactions.reason
        suggestionTextView.text = satisfactions.suggest
        dateLabel.text = satisfactions.date
        scoreLabel.text = satisfactions.score
        
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            titleLabel.font = UIFont.systemFont(ofSize: 27)
            reasonTextView.font = UIFont.systemFont(ofSize: 27)
            suggestionTextView.font = UIFont.systemFont(ofSize: 27)
            dateLabel.font = UIFont.systemFont(ofSize: 27)
            scoreLabel.font = UIFont.systemFont(ofSize: 27)
        }
        
    }
    
    @IBAction func tapSubmit(_ sender: Any) {
        let alert = UIAlertController(title: "確認", message: "確定修改滿意度紀錄？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "送出", style: .default, handler: { (action) in
            var itemInfo : [String : AnyObject] = [String : AnyObject]()
            itemInfo["score"] = self.scoreLabel.text as AnyObject
            itemInfo["reason"] = self.reasonTextView.text as AnyObject
            itemInfo["suggest"] = self.suggestionTextView.text as AnyObject
            itemInfo["date"] = self.dateLabel.text as AnyObject
            
            let ref = Database.database().reference().child("satisfaction").child(self.satisfactions.key)
            ref.updateChildValues(itemInfo){(err,reff) in
                if err != nil {
                    print("err\(err!)")
                    return
                }
            }
            self.navigationController?.popViewController(animated: true)        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func sliderChange(_ sender: Any) {
        scoreLabel.text = String(Int(scoreSlider.value*100))
    }
    
}
