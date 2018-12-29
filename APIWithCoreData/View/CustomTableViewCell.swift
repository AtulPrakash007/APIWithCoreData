//
//  CustomTableViewCell.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var expandBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func expandAction(_ sender: UIButton) {
    }
}
