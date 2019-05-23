//
//  FirstViewController.swift
//  BeNiMei
//
//  Created by user149927 on 1/6/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var addPerchaseCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var addPerchaseCollectionView: UICollectionView!
    @IBOutlet weak var myCollectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var productMenuSeg: UISegmentedControl!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var DarkBackgroundImageView: UIImageView!
    
    
    struct product {
        var name = String()
        var price = String()
        var description = String()
        var imagePath = String()
        var isSelected = Bool()
    }
    struct ordered {
        var name = String()
        var price = String()
    }
    
    var typeSegFlag : Bool = false
    
    // input some example data
    var serviceArray = [product]()
    var addPerchaseArray = [product]()
    var orderedArray = [ordered]()
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let refAddPerchase: DatabaseReference!  = Database.database().reference().child("addPerchase")
        addPerchaseArray = []
        refAddPerchase.queryOrderedByKey().observe(.childAdded, with:{ (snapshot) in
            var addPerchaseItem : product = product(name: "", price: "", description: "", imagePath: "", isSelected: false)
            if let dictionaryData = snapshot.value as? [String:AnyObject]{
                for item in dictionaryData{
                    switch item.key{
                    case "name":
                        addPerchaseItem.name = item.value as! String
                    case "price":
                        addPerchaseItem.price = item.value as! String
                    case "description":
                        addPerchaseItem.description = item.value as! String
                    case "imagePath":
                        addPerchaseItem.imagePath = item.value as! String
                    default:
                        break
                    }
                }
                self.addPerchaseArray.append(addPerchaseItem)
                self.myCollectionView.reloadData()
                self.addPerchaseCollectionView.reloadData()
            }
        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        showImageView.addGestureRecognizer(tapGesture)
        showImageView.isUserInteractionEnabled = true
        if Auth.auth().currentUser?.email == "admin@admin.com" {
            let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(callEditItemView))
            self.navigationItem.rightBarButtonItem = editButton
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        }
        else{
            
            self.tabBarController?.viewControllers?.remove(at: 2)
        }
        
        
        
        let navBackgroundImage = UIImage(named: "topbar_1200_120")
        self.navigationController!.navigationBar.setBackgroundImage(navBackgroundImage, for: .default)
        
        addPerchaseCollectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        addPerchaseCollectionViewLayout.itemSize = CGSize(width: fullScreenSize.width/2-20, height: fullScreenSize.height/2-40)
        addPerchaseCollectionViewLayout.minimumLineSpacing = 5
        myCollectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        myCollectionViewLayout.itemSize = CGSize(width: fullScreenSize.width/2-20, height: fullScreenSize.height/2-40) //設定cell的size
        myCollectionViewLayout.minimumLineSpacing = 5 //設定cell與cell間的縱距
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if typeSegFlag {
            let refAddPerchase: DatabaseReference!  = Database.database().reference().child("addPerchase")
            addPerchaseArray = []
            refAddPerchase.queryOrderedByKey().observe(.childAdded, with:{ (snapshot) in
                var addPerchaseItem : product = product(name: "", price: "", description: "", imagePath: "", isSelected: false)
                if let dictionaryData = snapshot.value as? [String:AnyObject]{
                    for item in dictionaryData{
                        switch item.key{
                        case "name":
                            addPerchaseItem.name = item.value as! String
                        case "price":
                            addPerchaseItem.price = item.value as! String
                        case "description":
                            addPerchaseItem.description = item.value as! String
                        case "imagePath":
                            addPerchaseItem.imagePath = item.value as! String
                        default:
                            break
                        }
                    }
                    self.addPerchaseArray.append(addPerchaseItem)
                }
                self.myCollectionView.reloadData()
                self.addPerchaseCollectionView.reloadData()
            })
            
        }
        else {
            let refService: DatabaseReference! = Database.database().reference().child("service")
            serviceArray = []
            refService.queryOrderedByKey().observe(.childAdded, with: {
                (snapshot) in
                
                var serviceItem : product = product(name: "", price: "", description: "", imagePath: "", isSelected: false)
                if let dictionaryData = snapshot.value as? [String: AnyObject] {
                    
                    //print(dictionaryData)
                    
                    for item in dictionaryData{
                        switch item.key{
                        case "name":
                            serviceItem.name = item.value as! String
                        //print(serviceItem.name)
                        case "price":
                            serviceItem.price = item.value as! String
                        case "description":
                            serviceItem.description = item.value as! String
                        case "imagePath":
                            serviceItem.imagePath = item.value as! String
                        default :break
                        }
                        
                    }
                    //print(serviceItem)
                    self.serviceArray.append(serviceItem)
                }
                self.myCollectionView.reloadData()
                self.addPerchaseCollectionView.reloadData()
            })
            
        }
    }
    
    @objc func callEditItemView(){
        if let controller = storyboard?.instantiateViewController(withIdentifier: "editItemView") as? EditItemViewController{
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.myCollectionView{
            return serviceArray.count
        }
        return addPerchaseArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.myCollectionView{
            
            let serviceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ServiceCollectionViewCell
            
            serviceCell.serviceNameButton.setTitle(self.serviceArray[indexPath.row].name, for: .normal)
            serviceCell.servicePriceLabel.text = String(self.serviceArray[indexPath.row].price)
            serviceCell.serviceDescriptionLabel.text = self.serviceArray[indexPath.row].description
            serviceCell.serviceImageButton.tag = indexPath.row
            serviceCell.serviceImageButton.addTarget(self, action: #selector(showImage), for: .touchUpInside)
            
            for (index, item) in serviceArray.enumerated(){
                let idx : IndexPath = [0,index]
                let tCell = myCollectionView.cellForItem(at: idx)
                if item.isSelected{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.694, green: 0.561, blue: 0.388, alpha: 1)
                }
                else{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.953, green: 0.941, blue: 0.867, alpha: 1)
                }
            }
            return serviceCell
        }
        else{
            let addPerchaseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "adPeCell", for: indexPath) as! AddPerchaseCollectionViewCell
            
            addPerchaseCell.addPerchaseNameButton.setTitle(self.addPerchaseArray[indexPath.row].name, for: .normal)
            addPerchaseCell.addPerchasePriceLabel.text = String(self.addPerchaseArray[indexPath.row].price)
            addPerchaseCell.addPerchaseDescriptionLabel.text = self.addPerchaseArray[indexPath.row].description
            addPerchaseCell.addPerchaseImageButton.tag = indexPath.row
            addPerchaseCell.addPerchaseImageButton.addTarget(self, action: #selector(showaPImage), for: .touchUpInside)
            
            for (index, item) in addPerchaseArray.enumerated(){
                let idx : IndexPath = [0,index]
                let tCell = addPerchaseCollectionView.cellForItem(at: idx)
                if item.isSelected{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.694, green: 0.561, blue: 0.388, alpha: 1)
                }
                else{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.953, green: 0.941, blue: 0.867, alpha: 1)
                }
            }
            return addPerchaseCell
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
        
        let pathRef = Storage.storage().reference().child("image/\(self.serviceArray[sender.tag].imagePath)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error {
                print(error)
            }
            else{
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = false
                self.showImageView.image = UIImage(data: data!)
            }
        }
    }
    @objc func showaPImage(sender: UIButton){
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
        
        let pathRef = Storage.storage().reference().child("image/\(self.addPerchaseArray[sender.tag].imagePath)")
        pathRef.getData(maxSize: 1*5120*5120) { (data, error) in
            if let error = error {
                print(error)
            }
            else{
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showImageView.isHidden = false
                self.showImageView.image = UIImage(data: data!)
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
    @IBAction func menuSegChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            myCollectionView.isHidden = false
            addPerchaseCollectionView.isHidden = true
            typeSegFlag = false
            myCollectionView.reloadData()
            addPerchaseCollectionView.reloadData()
            
        }
        else if sender.selectedSegmentIndex == 1 {
            myCollectionView.isHidden = true
            addPerchaseCollectionView.isHidden = false
            typeSegFlag = true
            myCollectionView.reloadData()
            addPerchaseCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.myCollectionView{
            
            let selectedCell:UICollectionViewCell = myCollectionView.cellForItem(at: indexPath)!
            
            if orderedArray.isEmpty {
                orderedArray.append(ordered(name: serviceArray[indexPath[1]].name, price: serviceArray[indexPath[1]].price))
                serviceArray[indexPath[1]].isSelected = true
            }
            else{
                var exist : Bool = false
                for eachElement in orderedArray{
                    if eachElement.name == serviceArray[indexPath[1]].name{
                        exist = true
                    }
                }
                if exist{
                    orderedArray = orderedArray.filter{$0.name != serviceArray[indexPath[1]].name}
                    serviceArray[indexPath[1]].isSelected = false
                }
                else{
                    orderedArray.append(ordered(name: serviceArray[indexPath[1]].name, price: serviceArray[indexPath[1]].price))
                    serviceArray[indexPath[1]].isSelected = true
                }
                
            }
            for (index, item) in serviceArray.enumerated(){
                let idx : IndexPath = [0,index]
                let tCell = myCollectionView.cellForItem(at: idx)
                if item.isSelected{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.694, green: 0.561, blue: 0.388, alpha: 1)
                }
                else{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.953, green: 0.941, blue: 0.867, alpha: 1)
                }
            }
        }
        else {
            
            let selectedCell:UICollectionViewCell = addPerchaseCollectionView.cellForItem(at: indexPath)!
            
            if orderedArray.isEmpty {
                orderedArray.append(ordered(name: addPerchaseArray[indexPath[1]].name, price: addPerchaseArray[indexPath[1]].price))
                addPerchaseArray[indexPath[1]].isSelected = true
            }
            else{
                var exist : Bool = false
                for eachElement in orderedArray{
                    if eachElement.name == addPerchaseArray[indexPath[1]].name{
                        exist = true
                    }
                }
                if exist{
                    orderedArray = orderedArray.filter{$0.name != addPerchaseArray[indexPath[1]].name}
                    addPerchaseArray[indexPath[1]].isSelected = false
                }
                else{
                    orderedArray.append(ordered(name: addPerchaseArray[indexPath[1]].name, price: addPerchaseArray[indexPath[1]].price))
                    addPerchaseArray[indexPath[1]].isSelected = true
                }
                
            }
            for (index, item) in addPerchaseArray.enumerated(){
                let idx : IndexPath = [0,index]
                let tCell = addPerchaseCollectionView.cellForItem(at: idx)
                if item.isSelected{
                    
                    tCell?.contentView.backgroundColor = UIColor(red: 0.694, green: 0.561, blue: 0.388, alpha: 1)
                }
                else{
                    tCell?.contentView.backgroundColor = UIColor(red: 0.953, green: 0.941, blue: 0.867, alpha: 1)
                }
            }
        }
        
              //selectedCell.contentView.backgroundColor = UIColor(displayP3Red: 0.694, green: 0.561, blue: 0.388, alpha: 1)
        //selectedCell.contentView.backgroundColor = UIColor(displayP3Red: 0.953, green: 0.941, blue: 0.867, alpha: 1)
        
        
        print(orderedArray)
        var totalPrice = 0
        for ordered in orderedArray{
            totalPrice = totalPrice + Int(ordered.price)! 
        }
        priceLabel.text = String(totalPrice)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var nameArray = [String]()
        var priceArray = [String]()
        for ordered in orderedArray {
            nameArray.append(ordered.name)
            priceArray.append(ordered.price)
        }
        if segue.identifier == "orderedToCustomerInfo" {
            let secondVC = segue.destination as! CustomerInfo
            secondVC.orderedNameArray = nameArray
            secondVC.orderePriceArray = priceArray
        }
    }
    @IBAction func reset(_ sender: Any) {
        for (index, _) in serviceArray.enumerated(){
            serviceArray[index].isSelected = false
        }

        for (index, _) in addPerchaseArray.enumerated(){
            addPerchaseArray[index].isSelected = false
        }
        orderedArray=[]
        priceLabel.text = "0"
    }
}
