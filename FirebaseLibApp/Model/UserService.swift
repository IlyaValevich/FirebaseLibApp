//
//  UserService.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 4/29/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    static var currentUserProfile:UserProfile?
    
    static func observeUserProfile(_ uid:String, completion: @escaping ((_ userProfile:UserProfile?)->())) {
        let userRef = Database.database().reference().child("users").child(uid)
        
        userRef.observe(.value, with: { snapshot in
            var userProfile:UserProfile?
            
            if let dict = snapshot.value as? [String:Any],
                let name = dict["name"] as? String,
                let surname = dict["surname"] as? String,
                let mail = dict["mail"] as? String,
                let isAdmin = dict["isAdmin"] as? Bool,
                let photoURL = dict["photoURL"] as? String,
                let url = URL(string:photoURL)
            {
                var photo:UIImage!
                
                ImageService.getImage(withURL: url) { image, url in
                    photo = image
                    print("image download")
                    userProfile = UserProfile(uid: snapshot.key, name: name, surname: surname, photoURL: url,  mail: mail,isAdmin:isAdmin)
                    completion(userProfile)
                }
                
            }
            
            // completion(userProfile)
        })
    }
    
}
