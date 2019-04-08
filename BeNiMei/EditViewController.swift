//
//  EditViewController.swift
//  BeNiMei
//
//  Created by apple on 2019/4/8.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var ItemTypeLabel: UILabel!
    @IBOutlet weak var ItemNameTextField: UITextField!
    @IBOutlet weak var ItemPriceTextField: UITextField!
    @IBOutlet weak var ItemDescriptionTextView: UITextView!
    @IBOutlet weak var ItemPhotoImageView: UIImageView!
    
    struct info {
        var type = String()
        var name = String()
        var price = String()
        var Description = String()
        var Image = String()
    }
    
    var carryInfo = info()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = "編輯項目"
        self.hideKeyboardWhenTappedAround()
        ItemTypeLabel.text = carryInfo.type
        ItemNameTextField.text = carryInfo.name
        ItemPriceTextField.text = carryInfo.price
        ItemDescriptionTextView.text = carryInfo.Description
    }
}
