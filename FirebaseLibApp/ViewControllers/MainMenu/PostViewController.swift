//
//  PostViewController.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/15/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase

class PostViewController:UIViewController {
    
    var user:UserProfile!
    var post:Post!
    var tags:[String]!
    var appreciatingUsers:[String:Double] = [:]
    
    fileprivate let tagsField = WSTagsField()
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var authorNameLabel: UILabel!
    
    @IBOutlet weak var bookNameLabel: UILabel!
   
    @IBOutlet fileprivate weak var tagView: UIView!
    
    @IBOutlet weak var usersVotes: CosmosView!
    
    @IBOutlet weak var autorVotes: CosmosView!
    
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var textLabel: UILabel!
    
    var modelController: PostController!
    
    static func makePostViewController(post: Post) -> PostViewController{
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        
        
        newViewController.post = post
        
        return newViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.post = modelController.postModel
        
        modelController.postModel = self.post
        self.authorNameLabel.text = post.postBookAuthor
        self.usernameLabel.text = post.author.name + " " + post.author.surname
        self.bookNameLabel.text = post.postBookName
        self.textLabel.text = post.postText
        self.usersVotes.rating = post.postUsersVotes
        //self.usersVotes.minTouchRating
        self.autorVotes.rating = post.postAuthorVotes
        //self.usersVotes.updateOnTouch = false
        self.autorVotes.updateOnTouch = false
       // self.postText.
        
        ImageService.getImage(withURL: post.author.photoURL ) { image, url in
            
            if self.post.author.photoURL.absoluteString == url.absoluteString {
                self.userImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
        
        ImageService.getImage(withURL: post.postImageURL) { image, url in
            
            if self.post.postImageURL.absoluteString == url.absoluteString {
                self.postImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
        
        let id = post.tags
        var tagList:[Tag] = []
        var ref: DatabaseReference!
        ref = Database.database().reference()
        for i in id{
            ref.child("tags").child(i).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String : AnyObject]
                
                let queue = DispatchQueue(label: "co")
                
                queue.async {
                    DispatchQueue.main.sync { // there's no deadlock
                        
                        //let tag = Tag(id: i, text: dictionary!["text"] as! String)
                        self.tagsField.addTag(dictionary!["text"] as! String)
                    }
                    print(tagList)
                }
            }, withCancel: nil)
            
            
        }
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        userImage.clipsToBounds = true
        tagsField.frame = tagView.bounds
        tagView.addSubview(tagsField)
        //tagsField.translatesAutoresizingMaskIntoConstraints = false
        //tagsField.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        tagsField.cornerRadius = 3.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10
        
        
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 18, left: 10, bottom: 10, right: 10) //old padding
        
        tagsField.readOnly = !tagsField.readOnly
        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = .lightGray
        tagsField.returnKeyType = .next
        tagsField.delimiter = ""
        tagsField.keyboardAppearance = .dark
        
        if post.author.uid == Auth.auth().currentUser!.uid{
            self.rateButton.setTitle("Edit", for: .normal)
            self.usersVotes.updateOnTouch = false
            
        }
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func postButton(_ sender: Any) {
        
//        var usersAppreciated:[String:Double] = [:]
//        let postRef = Database.database().reference().child("posts").child(self.post.id)
//        let usersAppreciatedRef = Database.database().reference().child("posts").child(self.post.id).child("usersAppreciated")
//
//        usersAppreciatedRef.observeSingleEvent(of: .value, with: { snapshot in
//            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
//                for snap in snapshots {
//                    usersAppreciated[snap.key] =  snap.value as! Double
//                    print(usersAppreciated)
//                }
//
//
//            }
//        })
       
        loadAppreciatingUsers{ success in
            if success{
                let postRef = Database.database().reference().child("posts").child(self.post.id)
                let usersAppreciatedRef = Database.database().reference().child("posts").child(self.post.id).child("usersAppreciated")
                print("!!!!!!!!!!!!!!!!!!")
                print(self.appreciatingUsers)
                for (uid, _) in self.appreciatingUsers{
                    if Auth.auth().currentUser?.uid == uid{
                        //
                        var newRating:Double = 0
                        for (_, rating) in self.appreciatingUsers{
                            newRating += rating
                        }
                        newRating /= Double(self.appreciatingUsers.count)
                        self.post.postUsersVotes = newRating
                        usersAppreciatedRef.updateChildValues([Auth.auth().currentUser?.uid: self.usersVotes.rating])
                        postRef.updateChildValues(["usersVotes":self.usersVotes.rating])
    
                        break
                    }
                    
                }
               
                //new user - new rate
                self.appreciatingUsers[Auth.auth().currentUser!.uid] = self.usersVotes.rating
                //[Auth.auth().currentUser?.uid:self.usersVotes.rating]
                usersAppreciatedRef.setValue(self.appreciatingUsers)
                var newRating:Double = 0
                for (_, rating) in self.appreciatingUsers{
                    newRating += rating
                }
                newRating /= Double(self.appreciatingUsers.count)
                postRef.updateChildValues(["usersVotes":newRating])
                self.post.postUsersVotes = newRating
                self.dismiss(animated: true, completion: nil)
                
            }
        }
        
}
    
    @IBAction func openUserProfile(_ sender: Any) {
        let user = self.post.author
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = UserProfileViewController.makeUserProfileViewController(user: user)
        vc.modelController = UserController()
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func loadAppreciatingUsers(completion: @escaping (Bool) -> ()){
        //var usersAppreciated:[String:Double] = [:]
        let postRef = Database.database().reference().child("posts").child(self.post.id)
        let usersAppreciatedRef = Database.database().reference().child("posts").child(self.post.id).child("usersAppreciated")
        
        usersAppreciatedRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    self.appreciatingUsers[snap.key] =  snap.value as! Double
                }
                completion(true)
            }
            })
        }
    
}
