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
    @IBOutlet weak var titleScoreLabel: UILabel!
    @IBOutlet weak var titleReasonLabel: UILabel!
    @IBOutlet weak var titleSuggestLabel: UILabel!
    @IBOutlet weak var titleDateLabel: UILabel!
    struct satisfaction {
        var key = String()
        var score = String()
        var reason = String()
        var suggest = String()
        var date = String()
    }
    
    var satisfactions : [satisfaction] = [satisfaction]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "滿意度"
        
        satisfactionTableView.delegate = self
        satisfactionTableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        satisfactions = []
        let ref : DatabaseReference = Database.database().reference().child("satisfaction")
        ref.queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                var sat = satisfaction()
                for item in dictionaryData{
                    sat.key = snapshot.key
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return satisfactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sCell", for: indexPath) as! SatisfactionTableViewCell
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            cell.scoreLabel.font = UIFont.systemFont(ofSize: 22)
            cell.reasonLabel.font = UIFont.systemFont(ofSize: 22)
            cell.suggestLabel.font = UIFont.systemFont(ofSize: 22)
            cell.dateLabel.font = UIFont.systemFont(ofSize: 22)
            cell.titleScoreLabel.font = UIFont.systemFont(ofSize: 22)
            cell.titleReasonLabel.font = UIFont.systemFont(ofSize: 22)
            cell.titleSuggestLabel.font = UIFont.systemFont(ofSize: 22)
            cell.titleDataLabel.font = UIFont.systemFont(ofSize: 22)
        }
        cell.scoreLabel.text = satisfactions[indexPath.row].score
        cell.reasonLabel.text = satisfactions[indexPath.row].reason
        cell.suggestLabel.text = satisfactions[indexPath.row].suggest
        cell.dateLabel.text = satisfactions[indexPath.row].date
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(tapEditButton), for: .touchUpInside)
        
        return cell
    }
    @objc func tapDeleteButton(sender: UIButton) {
        let alert = UIAlertController(title: "確認", message: "確定要刪除此筆滿意度紀錄?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: {action in
            Database.database().reference().child("satisfaction").child(self.satisfactions[sender.tag].key).removeValue()
            self.satisfactions.remove(at: sender.tag)
            self.satisfactionTableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func tapEditButton(sender: UIButton) {
        self.performSegue(withIdentifier: "editSat", sender: sender.tag)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tag = sender as! Int
        let controller = segue.destination as! EditSatisfactionViewController
        controller.satisfactions.key = self.satisfactions[tag].key
        controller.satisfactions.score = self.satisfactions[tag].score
        controller.satisfactions.reason = self.satisfactions[tag].reason
        controller.satisfactions.suggest = self.satisfactions[tag].suggest
        controller.satisfactions.date = self.satisfactions[tag].date
    }
}
