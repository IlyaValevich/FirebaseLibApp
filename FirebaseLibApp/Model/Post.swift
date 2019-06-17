//
//  Post.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/8/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class UsersAppreciated{
    var uid:String
    var vote:Double
    init(uid:String,vote:Double) {
        self.uid = uid
        self.vote = vote
    }
//    static func parse(_ key:String, _ data:[String:Any]) -> UsersAppreciated? {
//        if  let uid = data
//            let user = data[uid] as? [String:Any],
//            let uid = author["uid"] as? String,
//    }
}

class Post {
    var id:String
    var author:UserProfile
    var postText:String
    var postBookName:String
    var postBookAuthor:String
    //tags
    var tags: [String]
    var postAuthorVotes: Double
    var postUsersVotes: Double
    var postImageURL: URL
    var createdAt:Date
    var usersAppreciated:[String:Any] // id:rate
    init(id:String,
         author:UserProfile,
         postText:String,
         postBookName:String,
         postBookAuthor:String,
         postAuthorVotes: Double,
         postUsersVotes: Double,
         postImageURL: URL,
         timestamp:Double,
         tags:[String],
         usersAppreciated:[String:Any]
        ) {
        self.id = id
        self.author = author
        self.postText = postText
        self.postBookName = postBookName
        self.postBookAuthor = postBookAuthor
        self.postAuthorVotes = postAuthorVotes
        self.postUsersVotes = postUsersVotes
        self.postImageURL = postImageURL
        self.createdAt = Date(timeIntervalSince1970: timestamp / 1000)
        self.tags = tags
        self.usersAppreciated = usersAppreciated
    }
    static func parse(_ key:String, _ data:[String:Any]) -> Post? {
        if let author = data["author"] as? [String:Any],
            let uid = author["uid"] as? String,
            let name = author["name"] as? String,
            let surname = author["surname"] as? String,
            let photoURL = author["photoURL"] as? String,
            let url = URL(string:photoURL),
            let email = author["mail"] as? String,
            let isAdmin = author["isAdmin"] as? Bool,
            
            let text = data["text"] as? String,
            let bookName = data["bookName"] as? String,
            let bookAuthor = data["bookAuthor"] as? String,
            let authorVotes = data["authorVotes"] as? Double,
            let usersVotes = data["usersVotes"] as? Double,
            let imageURL = data["imageURL"] as? String,
            let postImageUrl = URL(string:imageURL),
            let timestamp = data["timestamp"] as? Double
        {

            let tagsId = data["tags"] as? [String] ?? []
          
            
            let usersAppreciated = data["usersAppreciated"] as? [String:Any] ?? [:]
            
            var userProfile:UserProfile
            userProfile = UserProfile(uid: uid, name: name, surname: surname, photoURL: url, mail: email, isAdmin: isAdmin)
            
            
            return Post(id: key, author: userProfile, postText: text, postBookName: bookName, postBookAuthor: bookAuthor, postAuthorVotes: authorVotes, postUsersVotes: usersVotes, postImageURL: postImageUrl, timestamp: timestamp, tags: tagsId, usersAppreciated: usersAppreciated)
        }
        
        return nil
    }
}

    func getUser(uid:String)-> UserProfile {
        var userProfile:UserProfile!
    

        fethUser(uid: uid){ userdd in
            userProfile = userdd
       
        }
        return userProfile
    }

    func fethUser(uid:String,completionHandler: @escaping (UserProfile) -> Void){
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        var userDictionary:[String:Any]!
        ref?.child("users").observeSingleEvent(of: .value, with: {( snapshot) in
            if let value = snapshot.value as? [String: Any] {
                print(value)
                let username = value["username"] as? String
                let name = value["name"] as? String ?? ""
                let surname = value["surname"] as? String ?? ""
                let photoURL = value["photoURL"] as? String ?? ""
                let url = URL(string:photoURL)
                let email = value["mail"] as? String ?? ""
                let isAdmin = value["isAdmin"] as? Bool ?? false
                let user = UserProfile(uid: snapshot.key, name: name, surname: surname, photoURL: url!, mail: email, isAdmin: isAdmin)
                print (user)
                completionHandler(user)
                
            }
            
        })
        
        
    }



