//
//  SatisfactionViewController.swift
//  BeNiMei
//
//  Created by user149927 on 2/28/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class SatisfactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var satisfactionTableView: UITableView!
    struct satisfaction {
        var score = String()
        var reason = String()
        var suggest = String()
        var date = String()
    }
    
    var satisfactions : [satisfaction] = [satisfaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "滿意度"
        
        let ref : DatabaseReference = Database.database().reference().child("satisfaction")
        ref.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                var sat = satisfaction()
                for item in dictionaryData{
                    switch item.key {
                    case "score":
                        sat.score = item.value as! String
                    case "reason":
                        sat.reason = item.value as! String
                    case "suggest":
                        sat.suggest = item.value as! String
                    case "date":
                        sat.date = item.value as! String
                    default:
                        break
                    }
                }
                self.satisfactions.append(sat)
            }
            self.satisfactions = self.satisfactions.reversed()
            self.satisfactionTableView.reloadData()
        })
        
        
        
        satisfactionTableView.delegate = self
        satisfactionTableView.dataSource = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return satisfactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sCell", for: indexPath) as! SatisfactionTableViewCell
        
        cell.scoreLabel.text = satisfactions[indexPath.row].score
        cell.reasonLabel.text = satisfactions[indexPath.row].reason
        cell.suggestLabel.text = satisfactions[indexPath.row].suggest
        cell.dateLabel.text = satisfactions[indexPath.row].date
        
        return cell
    }
    

}
