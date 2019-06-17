//
//  Tags.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/15/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import Firebase
class Tag {
    
    var id:String
    var text:String
    
    init(id:String,text:String) {
        self.id = id
        self.text = text
    }
   
}
func getTags(id:[String], completion: @escaping (_ tags:[Tag]?)->()) {
    var tagList:[Tag] = []
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    for i in id{
        ref.child("tags").child(i).observe(DataEventType.value, with:{ (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject] else {
                return
            }
            let tag = Tag(id: i, text: dictionary["text"] as! String)
            tagList.insert(tag, at: 0)
            completion(tagList)
        }, withCancel: nil)
    }
    
    completion(tagList)
}

//    func getTags(id:[String])->[Tag]{
//
//        var tagList:[Tag] = []
//        for i in id{
//            getTag(id:i){tag in
//                tagList.insert(tag!, at: 0)
//            }
//        }
//
//        return tagList
//
//    }
//
//    func getTag(id:String, completion: @escaping (_ tag:Tag?)->()) {
//        var tag:Tag!
//        var ref: DatabaseReference!
//
//        ref = Database.database().reference()
//
//        ref.child("tags").child(id).observe(DataEventType.value, with:{ (snapshot) in
//            guard let dictionary = snapshot.value as? [String : AnyObject] else {
//                return
//            }
//            tag = Tag(id: id, text: dictionary["text"] as! String)
//            completion(tag)
//        }, withCancel: nil)
//
//
//}
