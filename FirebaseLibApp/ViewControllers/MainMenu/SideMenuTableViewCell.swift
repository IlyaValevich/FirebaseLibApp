//
//  sideMenuTableViewCell.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/25/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//


import Firebase
import UIKit

class SideMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var textOption: UILabel!
    
    @IBOutlet weak var imageOption: UIImageView!
    
    func configureCell(option: Option) {
        self.textOption.text = option.textOption
        self.imageOption.image  = option.imageOption
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        }
    
}
