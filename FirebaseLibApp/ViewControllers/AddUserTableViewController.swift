//
//  AddUserTableViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 3/17/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
import UIKit
class AddUserTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var avatatImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
    }
    
    @IBAction func saveUser(sender:AnyObject){
        let name = nameTextField.text
        let position = positionTextField.text
    
        let newUser: NSDictionary = ["name" : name!, "position" : position!, "avatar" : "avatar"]
        let profile = ref.child(byAppendingPath : name!)
        profile.setValue(newUser)
        
        
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
