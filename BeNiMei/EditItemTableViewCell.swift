//
//  EditItemTableViewCell.swift
//  BeNiMei
//
//  Created by user149927 on 1/26/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit
class EditItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var editItemButton: UIButton!
    @IBOutlet weak var deleteItemButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
