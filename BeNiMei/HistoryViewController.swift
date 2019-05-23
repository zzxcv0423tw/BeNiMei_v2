//
//  HistoryViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/17/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase
//import SwiftCSVExport
//import MessageUI

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate{
    
    @IBOutlet weak var aTableView: UITableView!
    @IBOutlet weak var aSearchBar: UISearchBar!
    @IBOutlet weak var timePeriodStackView: UIStackView!
    @IBOutlet weak var timePeriodStartButton: UIButton!
    @IBOutlet weak var timePeriodEndButton: UIButton!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var DarkBackgroundImageView: UIImageView!
    
    struct cuInfo {
        var name = String()
        var phone = String()
        var date = String()
        var service = String()
        var price = String()
        var beautician = String()
        var imagePath = String()
    }
    
    
    var customerInfos : [cuInfo] = [cuInfo]()
    var filteredCuInfos = [cuInfo]()
    var searchController = UISearchController(searchResultsController: nil)
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = aSearchBar.delegate
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCuInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomHistoryTableViewCell
        
        cell.name.text = filteredCuInfos[indexPath.row].name
        cell.phone.text = filteredCuInfos[indexPath.row].phone
        cell.date.text = filteredCuInfos[indexPath.row].date
        cell.service.text = filteredCuInfos[indexPath.row].service
        cell.price.text = filteredCuInfos[indexPath.row].price
        cell.beautician.text = filteredCuInfos[indexPath.row].beautician
        cell.showPictureButton.tag = indexPath.row
        cell.showPictureButton.addTarget(self, action: #selector(showImage), for: .touchUpInside)
        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        dataLabel.backgroundColor = UIColor(patternImage: UIImage(named: "bg_150_200")!)
        
        let refCustomer : DatabaseReference! = Database.database().reference().child("customer")
        refCustomer.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            var customerItem : cuInfo = cuInfo(name: "", phone: "", date: "", service: "", price: "", beautician: "", imagePath: "")
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                
                var serviceItemArrayStr = String()
                
                for item in dictionaryData{
                    switch item.key {
                    case "name":
                        customerItem.name = item.value as! String
                    case "phone":
                        customerItem.phone = item.value as! String
                    case "date":
                        customerItem.date = item.value as! String
                    case "service":
                        serviceItemArrayStr = (snapshot.childSnapshot(forPath: "service").value as! [String]).joined(separator: ", ")
                        customerItem.service = serviceItemArrayStr
                    case "price":
                        customerItem.price = item.value as! String
                    case "beautician":
                        customerItem.beautician = item.value as! String
                    case "imagePath":
                        customerItem.imagePath = item.value as! String
                    default:
                        break
                    }
                }
                self.customerInfos.append(customerItem)
            }
            self.filteredCuInfos = self.customerInfos
            self.aTableView.reloadData()
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        showImageView.addGestureRecognizer(tapGesture)
        showImageView.isUserInteractionEnabled = true
        
        // Do any additional setup after loading the view.
        let navBackgroundImage = UIImage(named: "topbar_1200_120")
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
        
        setupSearchBar()
        
        filteredCuInfos = customerInfos
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //aTableView.tableHeaderView = searchController.searchBar
        
        aTableView.delegate = self
        aTableView.dataSource = self
        
        let statisticsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(callStatisticsView))
        self.navigationItem.rightBarButtonItem = statisticsButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        let satisfactionButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(callSatisfactionView))
        self.navigationItem.leftBarButtonItem = satisfactionButton
        //self.navigationItem.leftBarButtonItem?.t
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == ""{
            filteredCuInfos = customerInfos
        }
        else {
            filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(searchController.searchBar.text!.lowercased())} )
        }
        self.aTableView.reloadData()
    }
    
    func setupSearchBar(){
        aSearchBar.delegate = self
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if aSearchBar.text! == ""{
            filteredCuInfos = customerInfos
        }
        else {
            
        switch aSearchBar.selectedScopeButtonIndex {
            case 0:
                filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 1:
                filteredCuInfos = customerInfos.filter( {$0.phone.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 2:
                filteredCuInfos = customerInfos.filter( {$0.service.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 3:
                filteredCuInfos = customerInfos.filter( {$0.price.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 4:
                filteredCuInfos = customerInfos.filter( {$0.beautician.lowercased().contains(aSearchBar.text!.lowercased())} )
            default:
                break
            }
        }
        self.aTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        /*
        if selectedScope == 2 {
            timePeriodStackView.isHidden = false
            searchBar.text = ""
            searchBar.placeholder = "請於下方選擇時間"
        }
        else {
            timePeriodStackView.isHidden = true
            timePeriodStartButton.setTitle("開始", for: .normal)
            timePeriodEndButton.setTitle("結束", for: .normal)
            searchBar.placeholder = ""
        }
         */
        
        if aSearchBar.text! == ""{
            filteredCuInfos = customerInfos
        }
        else {
            
            switch aSearchBar.selectedScopeButtonIndex {
            case 0:
                filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 1:
                filteredCuInfos = customerInfos.filter( {$0.phone.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 2:
                filteredCuInfos = customerInfos.filter( {$0.service.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 3:
                filteredCuInfos = customerInfos.filter( {$0.price.lowercased().contains(aSearchBar.text!.lowercased())} )
            case 4:
                filteredCuInfos = customerInfos.filter( {$0.beautician.lowercased().contains(aSearchBar.text!.lowercased())} )
            default:
                 break
            }
        }
        self.aTableView.reloadData()
    }
    
    @objc func callStatisticsView(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "statisticsView") as? StatisticsViewController{
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func timePeriodStartButtonClick(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        datePicker.locale = Locale(identifier: "zh_TW")
        //datePicker.datePickerMode = UIDatePicker.Mode.date
        //datePicker.minuteInterval = 10
        vc.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "請選擇開始時間", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in

           let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let dateObj = dateFormatter.string(from: datePicker.date)
            self.timePeriodStartButton.setTitle(dateObj, for: .normal)
            
            if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                self.filteredCuInfos = self.customerInfos.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                        /*
                         if (dateStart?.compare(compaerDate!) == .orderedDescending && dateEnd?.compare(compaerDate!) == .orderedAscending){
                         return true
                         }*/
                    else {
                        return false
                    }
                } )
                
                self.aTableView.reloadData()
            }
        }))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = timePeriodStartButton
                currentPopoverpresentioncontroller.sourceRect = timePeriodStartButton.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func timePeriodEndButtonClick(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 400, height: 300)
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        datePicker.locale = Locale(identifier: "zh_TW")
        //datePicker.datePickerMode = UIDatePicker.Mode.date
        //datePicker.minuteInterval = 10
        vc.view.addSubview(datePicker)
        
        let alert = UIAlertController(title: "請選擇結束時間", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { (action) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd HH:mm"
            dateFormatter.locale = Locale.init(identifier: "zh_TW")
            let dateObj = dateFormatter.string(from: datePicker.date)
            self.timePeriodEndButton.setTitle(dateObj, for: .normal)
            
            
            if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                self.filteredCuInfos = self.customerInfos.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                    /*
                    if (dateStart?.compare(compaerDate!) == .orderedDescending && dateEnd?.compare(compaerDate!) == .orderedAscending){
                        return true
                    }*/
                    else {
                        return false
                    }
                } )
                
                self.aTableView.reloadData()
            }
        }))
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad )
        {
            if let currentPopoverpresentioncontroller = alert.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = timePeriodEndButton
                currentPopoverpresentioncontroller.sourceRect = timePeriodEndButton.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.up;
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func callSatisfactionView(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "satisfaction") as? SatisfactionViewController{
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    @objc func showImage(sender: UIButton){
        showImageView.layer.zPosition = 6
        self.DarkBackgroundImageView.layer.zPosition = 4
        self.DarkBackgroundImageView.isHidden = false
        self.activityIndicator.layer.zPosition = 5
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let pathRef = Storage.storage().reference().child("image/\(self.customerInfos[sender.tag].imagePath)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error {
                print(error)
            }
            else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = false
                self.showImageView.image = UIImage(data:data!)
            }
        }
    }
    @objc func imageTapped(gesture: UIGestureRecognizer){
        if let imageView = gesture.view as? UIImageView{
            showImageView.isHidden = true
            showImageView.image = nil
            self.DarkBackgroundImageView.isHidden = true
        }
    }
    @IBAction func exportClick(_ sender: Any) {
        print(filteredCuInfos)
    }
}
