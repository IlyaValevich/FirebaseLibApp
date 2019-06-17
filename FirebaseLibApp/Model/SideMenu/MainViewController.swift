//
//  MainViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/15/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
            
  
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(showCurrentUser),
//                                               name: NSNotification.Name("toCurrentUser"),
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(showNewPost),
//                                               name: NSNotification.Name("toNewPost"),
//                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSettingsProfile),
                                               name: NSNotification.Name("toSettings"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showSignIn),
                                               name: NSNotification.Name("toLoginScreen"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showUsersEdit),
                                               name: NSNotification.Name("toUsersEdit"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showTagEdit),
                                               name: NSNotification.Name("toTagEdit"),
                                               object: nil)

    }
    
    
   
//    @objc func showCurrentUser() {
//        
//        //performSegue(withIdentifier: "toCurrentUser", sender: nil)
//        
//        
//    }
    
//    @objc func showNewPost() {
//        performSegue(withIdentifier: "toNewPost", sender: nil)
//    }
    
    @objc func showSettingsProfile() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = UserProfileViewController.makeUserProfileViewController(user: UserService.currentUserProfile!)
        vc.modelController = UserController()
        
        self.present(vc, animated: true, completion: nil)
        
      //  performSegue(withIdentifier: "toSettings", sender: nil)
    }
    
    @objc func showSignIn() {
        
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.openViewController()
        
    }
    
    @objc func showTagEdit() {
        performSegue(withIdentifier: "toTagEdit", sender: nil)
    }
    
    @objc func showUsersEdit() {
        performSegue(withIdentifier: "toUsersEdit", sender: nil)
    }
    
    @IBAction func onMoreTapped() {
        print("TOGGLE SIDE MENU")
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        
    }


}
