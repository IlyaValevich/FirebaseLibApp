//
//  UserProfileViewController.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/9/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
class UserProfileViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    
    var posts = [Post]()
    
    var fetchingMore = false
    var endReached = false
    var refreshControl:UIRefreshControl!
    var lastUploadedPostID:String?
    
    let leadingScreensForBatching:CGFloat = 3.0
    
    var user : UserProfile!
    
    var subscribedUsers:[String:Bool] = [:]
    
    @IBOutlet weak var userFullName: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var frameImage: UIView!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var userPostTableView: UITableView!
    
    
    @IBOutlet weak var userEmail: UILabel!
    
    
    @IBOutlet weak var settingsUIBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var subscribeButton: UIButton!
    
    @IBOutlet weak var unsubscribeButton: UIButton!
    var modelController: UserController!
    
    static func makeUserProfileViewController(user: UserProfile) ->  UserProfileViewController {
    
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        
        
        newViewController.user = user
        
        return newViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPostTableView.delegate = self
        userPostTableView.dataSource = self
        userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
        userProfileImage.clipsToBounds = true
        frameImage.layer.cornerRadius = frameImage.bounds.height / 2
        frameImage.clipsToBounds = true
        
        
        
        self.userFullName.text = user.name + " " + user.surname
        self.userEmail.text = user.mail
        self.userProfileImage.image = nil
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.userProfileImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
        if(Auth.auth().currentUser?.uid == user.uid){
            subscribeButton.isEnabled = true
            subscribeButton.isHidden = true
            unsubscribeButton.isEnabled = true
            unsubscribeButton.isHidden = true

        }
        else{
            settingsUIBarButtonItem.isEnabled = true
            settingsUIBarButtonItem.tintColor = UIColor.clear
        }
        var isSub = false
        loadSubscribedUsers{ success in
            if success{
                print(self.subscribedUsers)
                for i in self.subscribedUsers {
                    if (i.key == self.user.uid){
                         isSub = true
                    }
                }
                if (isSub){
                   // self.unsubscribeButton.isEnabled = false
                  //self.unsubscribeButton.isHidden = false
                    self.subscribeButton.isEnabled = true
                self.subscribeButton.isHidden = true
                }else{
                    self.unsubscribeButton.isEnabled = true
                    self.unsubscribeButton.isHidden = true
                   // self.subscribeButton.isEnabled = false
                  // self.subscribeButton.isHidden = false
                }
                
                
            }
            else{
                //It is not updated and some error occurred. Do what you want.
            }
        }
       
        
        
     
        let cellNib = UINib(nibName: "PostCellTableViewCell", bundle: nil)
        userPostTableView.register(cellNib, forCellReuseIdentifier: "postCell")
        userPostTableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        userPostTableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)

        DataService.dataService.POST_REF.observe(DataEventType.value, with: { (snapshot) in
            print(snapshot.value)
            
            self.posts = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let id = snap.key
                        let  post =  Post.parse(id, postDictionary)
                            if post?.author.uid == self.user.uid{
                                self.posts.insert(post!, at: 0)
                            }
                        
                        
                    }
                }
                
            }
            
            self.userPostTableView.reloadData()
            
        })
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userModel = modelController
        userModel?.userModel = self.user

        self.userFullName.text = user.name + " " + user.surname
        self.userEmail.text = user.mail

        self.userProfileImage.image = nil
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.userProfileImage.image = image
            } else {
                print("Not the right image")
            }

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userModel = modelController
        userModel?.userModel = self.user
        if modelController.isChange {
            self.userFullName.text = user.name + " " + user.surname
            self.userEmail.text = user.mail
            self.userProfileImage.image = nil
            ImageService.getImage(withURL: user.photoURL ) { image, url in
                guard let _user = self.user else { return }
                if _user.photoURL.absoluteString == url.absoluteString {
                    self.userProfileImage.image = image
                } else {
                    print("Not the right image")
                }
                
            }
        
        }
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "UserProfileSettingsViewController") as? UserProfileSettingsViewController {
            let model = UserController()
            model.userModel = self.user
            viewController.modelController = model
            
            
            self.present(viewController, animated: true, completion: nil)
            
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCellTableViewCell
            cell.set(post: posts[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editVC = segue.destination as? UserProfileSettingsViewController {
            editVC.modelController = modelController
        }
    }
    
    
    
    @IBAction func subscribeAction(_ sender: Any) {
       // subscribeButton.isEnabled = true
       // subscribeButton.isHidden = true
        //unsubscribeButton.isEnabled = false
       // unsubscribeButton.isHidden = false
        loadSubscribedUsers{ success in
            if success{
                print(self.subscribedUsers)
                let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
                let subscribedUsersRef = userRef.child("subscribedUsers")
               
                self.subscribedUsers[self.user.uid] = true
                
                //n
                subscribedUsersRef.setValue(self.subscribedUsers)
             
                    self.unsubscribeButton.isEnabled = true
                    self.unsubscribeButton.isHidden = false
                    self.subscribeButton.isEnabled = false
                    self.subscribeButton.isHidden = true
             
              
                
                
            }
            else{
                //It is not updated and some error occurred. Do what you want.
            }
        }
    }
    
    @IBAction func unsubscribeAction(_ sender: Any) {
    
        loadSubscribedUsers{ success in
            if success{
                print(self.subscribedUsers)
                let userRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid)
                let subscribedUsersRef = userRef.child("subscribedUsers")
                
                self.subscribedUsers[self.user.uid] = false
                
                //n
                subscribedUsersRef.setValue(self.subscribedUsers)
           
                    self.unsubscribeButton.isEnabled = false
                    self.unsubscribeButton.isHidden = true
                    self.subscribeButton.isEnabled = true
                    self.subscribeButton.isHidden = false
            
                
                
            }
            else{
                //It is not updated and some error occurred. Do what you want.
            }
        }
    }
    
    func loadSubscribedUsers(completion: @escaping (Bool) -> ()){
        //var usersAppreciated:[String:Double] = [:]
        let subscribedUsersRef = Database.database().reference().child("users").child(Auth.auth().currentUser!.uid).child("subscribedUsers")
     
        
        subscribedUsersRef.observeSingleEvent(of: .value, with: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    self.subscribedUsers[snap.key] =  snap.value as? Bool
                }
                completion(true)
            }
        })
    }
    
}
extension UIScrollView {
    func updateContentView() {
        contentSize.height = subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height
    }
}
