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
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var dataCountFront: UILabel!
    @IBOutlet weak var dataCountAfter: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    
    @IBOutlet weak var titleNameLabel: UILabel!
    @IBOutlet weak var titlePhoneLabel: UILabel!
    @IBOutlet weak var titleDateLabel: UILabel!
    @IBOutlet weak var titleContentLabel: UILabel!
    @IBOutlet weak var titlePriceLabel: UILabel!
    @IBOutlet weak var titleBeauticianLabel: UILabel!
    
    struct cuInfo {
        var key = String()
        var name = String()
        var phone = String()
        var date = String()
        var service = String()
        var price = String()
        var beautician = String()
        var imagePath = String()
        var imagePath2 = String()
        var payment = String()
        var remark = String()
    }
    struct beauticianInfo {
        var key = String()
        var name = String()
        var email = String()
        var imagePath = String()
    }
    
    var currentBeautician = beauticianInfo()
    var beauticianInfos = [beauticianInfo]()
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
        
        if Auth.auth().currentUser?.email == "admin@admin.com" {
            cell.editButton.isHidden = false
            cell.deleteButton.isHidden = false
        }
        else {
            cell.editButton.isHidden = true
            cell.deleteButton.isHidden = true
        }
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            cell.name.font = UIFont.systemFont(ofSize: 22)
            cell.phone.font = UIFont.systemFont(ofSize: 22)
            cell.date.font = UIFont.systemFont(ofSize: 22)
            cell.service.font = UIFont.systemFont(ofSize: 22)
            cell.price.font = UIFont.systemFont(ofSize: 22)
            cell.beautician.font = UIFont.systemFont(ofSize: 22)
            cell.showPictureButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            cell.showAfterPictureButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            cell.paymentLabel.font = UIFont.systemFont(ofSize: 22)
            cell.remarkLabel.font = UIFont.systemFont(ofSize: 22)
        }
        cell.name.text = filteredCuInfos[indexPath.row].name
        cell.phone.text = filteredCuInfos[indexPath.row].phone
        cell.date.text = filteredCuInfos[indexPath.row].date
        cell.service.text = filteredCuInfos[indexPath.row].service
        cell.price.text = filteredCuInfos[indexPath.row].price
        cell.beautician.text = filteredCuInfos[indexPath.row].beautician
        cell.remarkLabel.text = filteredCuInfos[indexPath.row].remark
        cell.showPictureButton.tag = indexPath.row
        cell.showPictureButton.addTarget(self, action: #selector(showImage), for: .touchUpInside)
        cell.showAfterPictureButton.tag = indexPath.row
        cell.showAfterPictureButton.addTarget(self, action: #selector(showRemarkImage), for: .touchUpInside)
        cell.paymentLabel.text = filteredCuInfos[indexPath.row].payment
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(tapDeleteButton), for: .touchUpInside)
        cell.editButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(tapEditButton), for: .touchUpInside)
        return cell
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        dataLabel.backgroundColor = UIColor(patternImage: UIImage(named: "bg_150_200")!)
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        let tapGestureD = UITapGestureRecognizer(target: self, action: #selector(dBGTapped))
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
        
        if Auth.auth().currentUser?.email == "admin@admin.com" {
            let statisticsButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(callStatisticsView))
            self.navigationItem.rightBarButtonItem = statisticsButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            let satisfactionButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(callSatisfactionView))
            self.navigationItem.leftBarButtonItem = satisfactionButton
            //self.navigationItem.leftBarButtonItem?.t
        }
        
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            aSearchBar.setScopeBarButtonTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 22)], for: .normal)
            timePeriodStartButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            timePeriodEndButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
            dataCountFront.font = UIFont.systemFont(ofSize: 22)
            dataCountAfter.font = UIFont.systemFont(ofSize: 22)
            dataCountLabel.font = UIFont.systemFont(ofSize: 29)
            titleNameLabel.font = UIFont.systemFont(ofSize: 22)
            titlePhoneLabel.font = UIFont.systemFont(ofSize: 22)
            titleDateLabel.font = UIFont.systemFont(ofSize: 22)
            titlePriceLabel.font = UIFont.systemFont(ofSize: 22)
            titleContentLabel.font = UIFont.systemFont(ofSize: 22)
            titleBeauticianLabel.font = UIFont.systemFont(ofSize: 22)
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
                print("beautician")
                print(beautician)
                self.beauticianInfos.append(beautician)
            }
            print("beauticianInfos : ")
            print(self.beauticianInfos)
            for item in self.beauticianInfos {
                if (Auth.auth().currentUser?.email == item.email) {
                    self.currentBeautician.key = item.key
                    self.currentBeautician.name = item.name
                    self.currentBeautician.email = item.email
                    self.currentBeautician.imagePath = item.imagePath
                }
            }
            print("currentBeautician : ")
            print(self.currentBeautician)
        }
        
        customerInfos = [cuInfo]()
        filteredCuInfos = [cuInfo]()
        let refCustomer : DatabaseReference! = Database.database().reference().child("customer")
        refCustomer.queryOrderedByKey().observe(.childAdded, with: {(snapshot) in
            var customerItem : cuInfo = cuInfo(key: "", name: "", phone: "", date: "", service: "", price: "", beautician: "", imagePath: "",imagePath2: "", payment: "", remark: "")
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                
                var serviceItemArrayStr = String()
                
                for item in dictionaryData{
                    customerItem.key = snapshot.key
                    switch item.key {
                    case "name":
                        customerItem.name = item.value as! String
                    case "phone":
                        customerItem.phone = item.value as! String
                    case "date":
                        customerItem.date = item.value as! String
                    case "service":
                        serviceItemArrayStr = (snapshot.childSnapshot(forPath: "service").value as! [String]).joined(separator: "\r\n")
                        customerItem.service = serviceItemArrayStr
                    case "price":
                        customerItem.price = item.value as! String
                    case "beautician":
                        customerItem.beautician = item.value as! String
                    case "imagePath":
                        customerItem.imagePath = item.value as! String
                    case "imagePath2":
                        customerItem.imagePath2 = item.value as! String
                    case "payment":
                        if (item.value as! String) == "cash" {
                            customerItem.payment = "現金支付"
                        } else if (item.value as! String) == "transfer" {
                            customerItem.payment = "匯款支付"
                        } else {
                            customerItem.payment = "其他"
                        }
                    case "remark":
                        customerItem.remark = item.value as! String
                    default:
                        break
                    }
                }
                self.customerInfos.append(customerItem)
            }
            if Auth.auth().currentUser?.email != "admin@admin.com"{
                self.customerInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.currentBeautician.name.lowercased())} )
            }
            if self.aSearchBar.text! == ""{
                self.filteredCuInfos = self.customerInfos
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.dataCountLabel.text = String(self.filteredCuInfos.count)
                    self.aTableView.reloadData()
                }
            }
            else {
                
                switch self.aSearchBar.selectedScopeButtonIndex {
                case 0:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.name.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 1:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.phone.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 2:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.service.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 3:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.price.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 4:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                default:
                    break
                }
            }
            self.dataCountLabel.text = String(self.filteredCuInfos.count)
            self.aTableView.reloadData()
        })
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! == ""{
            filteredCuInfos = customerInfos
        }
        else {
            filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(searchController.searchBar.text!.lowercased())} )
        }
        dataCountLabel.text = String(self.filteredCuInfos.count)
        self.aTableView.reloadData()
    }
    
    func setupSearchBar(){
        aSearchBar.delegate = self
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if aSearchBar.text! == ""{
            filteredCuInfos = customerInfos
            if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                self.filteredCuInfos = self.filteredCuInfos.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                    else {
                        return false
                    }
                } )
                dataCountLabel.text = String(self.filteredCuInfos.count)
                self.aTableView.reloadData()
            }
        }
        else {
            
        switch aSearchBar.selectedScopeButtonIndex {
            case 0:
                filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
            }
            case 1:
                filteredCuInfos = customerInfos.filter( {$0.phone.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
            }
            case 2:
                filteredCuInfos = customerInfos.filter( {$0.service.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
            }
            case 3:
                filteredCuInfos = customerInfos.filter( {$0.price.lowercased().contains(aSearchBar.text!.lowercased())} )
                
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            case 4:
                filteredCuInfos = customerInfos.filter( {$0.beautician.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
            }
            default:
                break
            }
        }
        dataCountLabel.text = String(self.filteredCuInfos.count)
        self.aTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        if aSearchBar.text! == ""{
            filteredCuInfos = customerInfos
            if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/dd HH:mm"
                formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                self.filteredCuInfos = self.filteredCuInfos.filter( {
                    
                    let compaerDate = formatter.date(from: $0.date)
                    if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                        return true
                    }
                    else {
                        return false
                    }
                } )
                
                dataCountLabel.text = String(self.filteredCuInfos.count)
                self.aTableView.reloadData()
            }
        }
        else {
            
            switch aSearchBar.selectedScopeButtonIndex {
            case 0:
                filteredCuInfos = customerInfos.filter( {$0.name.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            case 1:
                filteredCuInfos = customerInfos.filter( {$0.phone.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            case 2:
                filteredCuInfos = customerInfos.filter( {$0.service.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            case 3:
                filteredCuInfos = customerInfos.filter( {$0.price.lowercased().contains(aSearchBar.text!.lowercased())} )
                
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            case 4:
                filteredCuInfos = customerInfos.filter( {$0.beautician.lowercased().contains(aSearchBar.text!.lowercased())} )
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.aTableView.reloadData()
                }
            default:
                 break
            }
        }
        dataCountLabel.text = String(self.filteredCuInfos.count)
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
            
            if self.aSearchBar.text! == ""{
                self.filteredCuInfos = self.customerInfos
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.dataCountLabel.text = String(self.filteredCuInfos.count)
                    self.aTableView.reloadData()
                }
            }
            else {
                
                switch self.aSearchBar.selectedScopeButtonIndex {
                case 0:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.name.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 1:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.phone.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 2:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.service.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 3:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.price.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 4:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                default:
                    break
                }
            }
            self.dataCountLabel.text = String(self.filteredCuInfos.count)
            self.aTableView.reloadData()
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
            
            
            
            if self.aSearchBar.text! == ""{
                self.filteredCuInfos = self.customerInfos
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.dataCountLabel.text = String(self.filteredCuInfos.count)
                    self.aTableView.reloadData()
                }
            }
            else {
                
                switch self.aSearchBar.selectedScopeButtonIndex {
                case 0:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.name.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 1:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.phone.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 2:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.service.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 3:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.price.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 4:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                default:
                    break
                }
            }
            self.dataCountLabel.text = String(self.filteredCuInfos.count)
            self.aTableView.reloadData()
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
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = true
                self.DarkBackgroundImageView.isHidden = true
                let alertController = UIAlertController(title: "圖片讀取失敗！",
                                                        message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
            }
            else {
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = false
                self.showImageView.image = UIImage(data:data!)
            }
        }
    }
    @objc func showRemarkImage(sender: UIButton){
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
        
        let pathRef = Storage.storage().reference().child("image/\(self.customerInfos[sender.tag].imagePath2)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error {
                print(error)
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = true
                self.DarkBackgroundImageView.isHidden = true
                let alertController = UIAlertController(title: "圖片讀取失敗！",
                                                        message: nil, preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: false, completion: nil)
                }
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
    @objc func dBGTapped(gesture: UIGestureRecognizer){
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showImageView.isHidden = true
        self.DarkBackgroundImageView.isHidden = true
    }
    @IBAction func exportClick(_ sender: Any) {
        var outputData : String = "客戶, 手機, 日期, 服務, 價格, 美容師, 付款方式\r\n"
        for eachdata in filteredCuInfos {
            outputData.append(eachdata.name)
            outputData.append(", ")
            outputData.append(eachdata.phone)
            outputData.append(", ")
            outputData.append(eachdata.date)
            outputData.append(", ")
            let serviceForamt = eachdata.service.components(separatedBy: "\r\n")
            for eachService in serviceForamt {
                outputData.append(eachService)
                outputData.append("、")
            }
            outputData.removeLast()
            outputData.append(", ")
            outputData.append(eachdata.price)
            outputData.append(", ")
            outputData.append(eachdata.beautician)
            outputData.append(", ")
            outputData.append(eachdata.payment)
            outputData.append("\r\n")
        }
        
        let fileName = "BeNiMei.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
            do {
                try outputData.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                
                let vc = UIActivityViewController(activityItems: [path as Any], applicationActivities: [])
                present(vc, animated: true, completion: nil)
                if let popOver = vc.popoverPresentationController {
                    popOver.sourceView = exportButton
                }
            } catch {
                
                print("Failed to create file")
                print("\(error)")
            }
    }
    @IBAction func timePeroidClear(_ sender: Any) {
        self.timePeriodStartButton.setTitle("開始", for: .normal)
        self.timePeriodEndButton.setTitle("結束", for: .normal)
        
        if self.aSearchBar.text! == ""{
            self.filteredCuInfos = self.customerInfos
            dataCountLabel.text = String(self.filteredCuInfos.count)
            self.aTableView.reloadData()
        }
        else {
            
            switch self.aSearchBar.selectedScopeButtonIndex {
            case 0:
                self.filteredCuInfos = self.customerInfos.filter( {$0.name.lowercased().contains(self.aSearchBar.text!.lowercased())} )
            case 1:
                self.filteredCuInfos = self.customerInfos.filter( {$0.phone.lowercased().contains(self.aSearchBar.text!.lowercased())} )
            case 2:
                self.filteredCuInfos = self.customerInfos.filter( {$0.service.lowercased().contains(self.aSearchBar.text!.lowercased())} )
            case 3:
                self.filteredCuInfos = self.customerInfos.filter( {$0.price.lowercased().contains(self.aSearchBar.text!.lowercased())} )
            case 4:
                self.filteredCuInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.aSearchBar.text!.lowercased())} )
            default:
                break
            }
        }
        
        dataCountLabel.text = String(self.filteredCuInfos.count)
        self.aTableView.reloadData()
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    @objc func tapDeleteButton(sender: UIButton) {
        let alert = UIAlertController(title: "確認", message: "確定要刪除此筆歷史紀錄?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: {action in
            
            //刪除圖片
            let desertRef = Storage.storage().reference().child("image").child(self.filteredCuInfos[sender.tag].imagePath)
            desertRef.delete(completion: { (error) in
                if let error = error {
                    print(error)
                }
                else {
                    //delete successful !
                }
            })
            let desertRef2 = Storage.storage().reference().child("image").child(self.filteredCuInfos[sender.tag].imagePath2)
            desertRef2.delete(completion: { (error) in
                if let error = error {
                    print(error)
                }
                else {
                    //delete successful !
                }
            })
            
            Database.database().reference().child("customer").child(self.filteredCuInfos[sender.tag].key).removeValue()
            
            self.customerInfos.remove(at: sender.tag)
            self.filteredCuInfos = self.customerInfos
            if self.aSearchBar.text! == ""{
                self.filteredCuInfos = self.customerInfos
                if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yy/MM/dd HH:mm"
                    formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                    let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                    let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                    self.filteredCuInfos = self.filteredCuInfos.filter( {
                        
                        let compaerDate = formatter.date(from: $0.date)
                        if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                            return true
                        }
                        else {
                            return false
                        }
                    } )
                    
                    self.dataCountLabel.text = String(self.filteredCuInfos.count)
                    self.aTableView.reloadData()
                }
            }
            else {
                
                switch self.aSearchBar.selectedScopeButtonIndex {
                case 0:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.name.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 1:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.phone.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 2:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.service.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 3:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.price.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                case 4:
                    self.filteredCuInfos = self.customerInfos.filter( {$0.beautician.lowercased().contains(self.aSearchBar.text!.lowercased())} )
                    if self.timePeriodStartButton.currentTitle != "開始" && self.timePeriodEndButton.currentTitle != "結束"{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yy/MM/dd HH:mm"
                        formatter.timeZone = NSTimeZone(name: "UTC") as! TimeZone
                        let dateStart : NSDate = formatter.date(from: self.timePeriodStartButton.currentTitle ?? "0") as! NSDate
                        let dateEnd : NSDate = formatter.date(from: self.timePeriodEndButton.currentTitle ?? "0") as! NSDate
                        self.filteredCuInfos = self.filteredCuInfos.filter( {
                            
                            let compaerDate = formatter.date(from: $0.date)
                            if dateStart.earlierDate(compaerDate!) == dateStart as Date && dateEnd.laterDate(compaerDate!) == dateEnd as Date{
                                return true
                            }
                            else {
                                return false
                            }
                        } )
                        
                        self.aTableView.reloadData()
                    }
                default:
                    break
                }
            }
            self.aTableView.reloadData()
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc func tapEditButton(sender: UIButton) {
        self.performSegue(withIdentifier: "sendEditHistory", sender: sender.tag)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tag = sender as! Int
        let controller = segue.destination as! EditHistoryViewController
        
        controller.carryInfo.key = self.filteredCuInfos[tag].key
        controller.carryInfo.name = self.filteredCuInfos[tag].name
        controller.carryInfo.phone = self.filteredCuInfos[tag].phone
        controller.carryInfo.date = self.filteredCuInfos[tag].date
        controller.carryInfo.service = self.filteredCuInfos[tag].service
        controller.carryInfo.price = self.filteredCuInfos[tag].price
        controller.carryInfo.beautician = self.filteredCuInfos[tag].beautician
        controller.carryInfo.imagePath = self.filteredCuInfos[tag].imagePath
        controller.carryInfo.payment = self.filteredCuInfos[tag].payment
        controller.carryInfo.remark = self.filteredCuInfos[tag].remark
        controller.carryInfo.imagePath2 = self.filteredCuInfos[tag].imagePath2
    }
}
