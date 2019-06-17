//
//  DataService.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/8/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import Firebase
import UIKit
class DataService {
    //class to simplify work with the database, was useless(
    
    static let dataService = DataService()
    
    public var userID = Auth.auth().currentUser?.uid
    
    private var _BASE_REF = Database.database().reference()
    
    private var _USER_REF = Database.database().reference().child("users")
    
    private var _POST_REF = Database.database().reference().child("posts")
    
    private var _TAG_REF = Database.database().reference().child("tags")
    
    private var _STORAGE_REF = Storage.storage().reference()
    
    var BASE_REF: DatabaseReference {
        return _BASE_REF
    }
    
    var USER_REF: DatabaseReference {
        return _USER_REF
    }
    var TAG_REF: DatabaseReference {
        return _TAG_REF
    }
    var STORAGE_REF: StorageReference {
        return _STORAGE_REF
    }
    
    var CURRENT_USER_REF: DatabaseReference {
        
        let currentUser = BASE_REF.child("users").child(userID!)
        print("here \(currentUser)")
        
        return currentUser
    }
    
    var POST_REF: DatabaseReference {
        return _POST_REF
    }
    
    var uid: String {
        return userID!
    }
    
    //MARK - get current user id
    
    var CURRENT_USER_ID_REF:DatabaseReference{
        //  let userID = Auth.auth().currentUser!.uid as! String
        
        let currentUserId = BASE_REF.child("users").child(userID!)
        
        return currentUserId
    }
    
    //MARK - get current user mail
    var CURRENT_USER_MAIL_REF:DatabaseReference{
        // let userID = Auth.auth().currentUser!.uid as! String
        
        let currentUserMail = BASE_REF.child("users").child(userID!).child("mail")
        
        return currentUserMail
    }
    
    var CURRENT_USER_PROFILE_IMAGE_REF:DatabaseReference{
        //let userID = Auth.auth().currentUser!.uid as! String
        
        let currentUserIsAdmin = BASE_REF.child("users").child(userID!).child("photoURL")
        
        return currentUserIsAdmin
    }
    
    //MARK - get curretn user admin status
    var CURRENT_USER_IS_ADMIN_REF:DatabaseReference{
        // let userID = Auth.auth().currentUser!.uid as! String
        
        let currentUserProfileImage = BASE_REF.child("users").child(userID!).child("isAdmin")
        
        return currentUserProfileImage
    }
    
    var TAGS:DatabaseReference{
        
        let currentUserProfileImage = BASE_REF.child("tags")
        
        return currentUserProfileImage
    }
    
    var USERS_IMAGE: StorageReference{
        
        let usersImageReference = STORAGE_REF.child("users")
        
        return usersImageReference
    }
    
    var POSTS_IMAGE: StorageReference{
        let postsImageReference = STORAGE_REF.child("post")
        
        return postsImageReference
    }
    
    func createNewPost(post: Dictionary<String, AnyObject>) {
        
        let firebaseNewPost = POST_REF.childByAutoId()
        firebaseNewPost.setValue(post)
        
        print("post set")
    }
    
    func createNewTag(tag: Dictionary<String, AnyObject>) {
        
        let firebaseNewTag = TAG_REF.childByAutoId()
        firebaseNewTag .setValue(tag)
        
        print("tag set")
    }
    
    func createNewUser(uid: String, user: Dictionary<String, String>) {
        
        USER_REF.child(byAppendingPath: uid).setValue(user)
        
        print("users set")
    }
    
    func updatePost(uid: String, post: Dictionary<String, String>) {
        
        POST_REF.child(byAppendingPath: uid).updateChildValues(post)
        
        
        print("post change")
    }
    
    func updateTag(uid: String, tag: Dictionary<String, String>) {
        
        TAG_REF.child(byAppendingPath: uid).updateChildValues(tag)
        
        print("tag set")
    }
    
    func updateUser(uid: String, user: Dictionary<String, String>) {
        
        USER_REF.child(byAppendingPath: uid).updateChildValues(user)
        
        print("users set")
    }
    
    func deleteUser(uid: String) {
        
        var user = Auth.auth().currentUser;
        
        user?.delete()
        
    }
}
