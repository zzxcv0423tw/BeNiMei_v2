//
//  CustomHistoryTableViewCell.swift
//  BeNiMei
//
//  Created by user149927 on 1/17/19.
//  Copyright © 2019 Levi. All rights reserved.
//

import UIKit

class CustomHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var beautician: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
