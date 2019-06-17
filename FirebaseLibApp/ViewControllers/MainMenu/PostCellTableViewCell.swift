//
//  PostCellTableViewCell.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 4/28/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
//Castom cell
import Firebase

class PostCellTableViewCell: UITableViewCell {
    
        @IBOutlet weak var postBookName: UILabel!
        
        @IBOutlet weak var postBookAuthor: UILabel!
        @IBOutlet weak var postText: UILabel!
        @IBOutlet weak var nameLabel: UILabel!
        @IBOutlet weak var surnameLabel: UILabel!
        @IBOutlet weak var profileImageView: UIImageView!
        @IBOutlet weak var subtitleLabel: UILabel!
        @IBOutlet weak var postTextLabel: UILabel!
        @IBOutlet weak var postImageView: UIImageView!
        
    @IBOutlet weak var authorRate: CosmosView!
    @IBOutlet weak var usersRate: CosmosView!
    
        override func awakeFromNib() {
            super.awakeFromNib()
            // Initialization code
            
            profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
            profileImageView.clipsToBounds = true
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Configure the view for the selected state
        }
        
        weak var post:Post?
        
        func set(post:Post) {
            self.post = post
            
            self.profileImageView.image = nil
            ImageService.getImage(withURL: post.author.photoURL) { image, url in
                guard let _post = self.post else { return }
                if _post.author.photoURL.absoluteString == url.absoluteString {
                    self.profileImageView.image = image
                } else {
                    print("Not the right image")
                }
                
            }
            self.postImageView.image = nil
            ImageService.getImage(withURL: post.postImageURL) { image, url in
                guard let _post = self.post else { return }
                if _post.postImageURL.absoluteString == url.absoluteString {
                    self.postImageView.image = image
                } else {
                    print("Not the right image")
                }
                
            }
            self.postBookName.text = post.postBookName
            self.nameLabel.text = post.author.name + " " + post.author.surname
            //urnameLabel.text = post.author.surname
            self.postText.text = post.postText
            self.subtitleLabel.text = post.createdAt.calenderTimeSinceNow()
            self.authorRate.rating = post.postAuthorVotes
            self.usersRate.rating = post.postUsersVotes
            
        }
        
        
}
