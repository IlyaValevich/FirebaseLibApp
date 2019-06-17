//
//  UserProfile.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 4/29/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import UIKit
class UserProfile {
    var uid:String
    var name:String
    var surname:String
    var photoURL:URL
    var mail:String
    var isAdmin:Bool
    init(uid:String, name:String, surname:String, photoURL:URL, mail:String,isAdmin:Bool) {
        self.uid = uid
        self.name = name
        self.surname = surname
        self.photoURL = photoURL
        self.mail = mail
        self.isAdmin = isAdmin
    }
    init(key:String,data:[String:Any]) {
        print("parse UserProfile")
        let name = data["name"] as? String
        let surname = data["surname"] as? String
        let photoURL = data["photoURL"] as? String
        let url = URL(string:photoURL!)
        let email = data["mail"] as? String
        let isAdmin = data["isAdmin"] as? Bool
        self.uid = key
        self.name = name!
        self.surname = surname!
        self.photoURL = url!
        self.mail = email!
        self.isAdmin = isAdmin!
        
        
    }
    static func parse(_ key:String, _ data:[String:Any]) -> UserProfile? {
        print("parse UserProfile")
        if  let name = data["name"] as? String,
            let surname = data["surname"] as? String,
            let photoURL = data["photoURL"] as? String,
            let url = URL(string:photoURL),
            let email = data["mail"] as? String,
            let isAdmin = data["isAdmin"] as? Bool
        {
            let userProfile = UserProfile(uid: key, name: name, surname: surname, photoURL: url, mail: email, isAdmin: isAdmin)
            
            return userProfile
            
            
        }
        
        return nil
    }
}
