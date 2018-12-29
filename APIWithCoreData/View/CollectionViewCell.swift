//
//  CollectionViewCell.swift
//  APIWithCoreData
//
//  Created by Atul on 27/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var sizeLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellSetup()
    }
    
    func cellSetup() {
        self.layer.cornerRadius = self.frame.size.width/5
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }

}
