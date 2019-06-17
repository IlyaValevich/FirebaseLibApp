//
//  Notifications.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 6/17/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
class Notifications: NSObject, UNUserNotificationCenterDelegate {
    
    var subscribedUsers:[String:Bool] = [:]

    var posts = [Post]()
    
    var count = 0
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func userRequest() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleNotification(notificationType: String) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let userActions = "User Actions"
        
        loadSubscribedUsers{ success in
            if success{
                print(self.subscribedUsers)
                
            }
            else{
                content.body = "Notification error"
            }
        }
        loadNewPost{ success in
            if success{
                print(self.posts)
                content.title = notificationType
                content.body = "Your followers have \(self.posts.count) new reviews"
                content.sound = UNNotificationSound.default
                content.badge = 1
                content.categoryIdentifier = userActions
                
                
                
                let date = Date(timeIntervalSinceNow: 3600)
                let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute, .second,], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
                let identifier = "Local Notification"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                self.notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error \(error.localizedDescription)")
                    }
                }
                
                let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
                let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
                let category = UNNotificationCategory(identifier: userActions,
                                                      actions: [snoozeAction, deleteAction],
                                                      intentIdentifiers: [],
                                                      options: [])
                
                self.notificationCenter.setNotificationCategories([category])
            }
            else{
                content.body = "Notification error"
            }
        }
        
        
        
        
       
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
            scheduleNotification(notificationType: "sdfd")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        completionHandler()
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
    
    func loadNewPost(completion: @escaping (Bool) -> ()){
        
       
        let postsRef = Database.database().reference().child("posts")
            
        self.posts = []
  
        postsRef.observe(DataEventType.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let id = snap.key
                        let dateNow = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                        let  post =  Post.parse(id, postDictionary)
                        for i in self.subscribedUsers{
                            if (post?.author.uid == i.key
                                && i.value == true){
                                if ((Calendar.current.dateComponents([.day], from: dateNow!, to: post!.createdAt).day!) > 0) {
                                self.posts.insert(post!, at: 0)
                                }
                            }
                        }
                        
                    }
                }
                completion(true)
           
            }
        })
    }
        
        
        
    
}
