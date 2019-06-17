//
//  TagTableViewCell.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/14/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {
    @IBOutlet weak var tagTextLabel: UILabel!
    @IBOutlet weak var tagSelectImage: UIImageView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func set(tag:String) {
        self.textLabel?.text = tag
       
        
    }
    
//    @IBAction func tapSelect(_ sender: Any) {
//      sele
//    }
}
