//
//  UserTableViewCell.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/6/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }

    weak var user:UserProfile?
    
    func set(user:UserProfile) {
        self.user = user
        
        self.profileImageView.image = nil
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.profileImageView.image = image
            } else {
                print("Not the right image")
            }
            
        }
        
        self.fullNameLabel.text = user.name + " " + user.surname
    
    
    }
    
}
