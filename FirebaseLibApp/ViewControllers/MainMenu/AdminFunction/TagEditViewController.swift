//
//  TagEditViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/24/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//


import Firebase
import UIKit


class TagEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tagTableView: UITableView!
    
    @IBOutlet weak var tagTextField: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var tags = [String]()
    
    var searchedTags = [String]()
    
    var searching = false
    
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var textIsChange = false
    
    var textIsFirstUpdate = true
    
    override func viewDidLoad() {
        registerKeyboardNotification()
        super.viewDidLoad()
        tagTableView.delegate = self
        tagTableView.dataSource = self
        searchBar.delegate = self
        activityView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        activityView.style = .whiteLarge
        activityView.backgroundColor = .green
        activityView.layer.cornerRadius = activityView.bounds.height / 2
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
        activityView.startAnimating()
        
        Database.database().reference().child("tags").observe(DataEventType.value, with: { snapshot in
            self.tags = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let userDictionary = snap.value as? Dictionary<String, AnyObject> {
                        
                        let text = userDictionary["text"] as? String
                        
                        self.tags.insert(text!, at: 0)
                    }
                }
                
            }
            self.activityView.stopAnimating()
            self.searchedTags = self.tags
            self.tagTableView.reloadData()
            
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTags.count // return the total items in the items array
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tag = searchedTags[indexPath.row]
        
        // We are using a custom cell.
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell") as? TagTableViewCell {
            
            cell.set(tag: tag)
            
            return cell
            
        } else {
            print("cell fail")
            return UserTableViewCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let tag = tags[indexPath.row]
        print(tag)
        
        Database.database().reference().child("tags").observeSingleEvent(of: .value, with:{ snapshot in
            self.tags = []
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let tagDictionary = snap.value as? Dictionary<String, AnyObject> {
                        
                        if tag == tagDictionary["text"] as? String{
                            Database.database().reference().child("tags").child(snap.key).removeValue()
                        }
                        
                        
                    }
                }
                
            }
            
            self.tagTableView.reloadData()
            
        })
        
        
        
    }
    
    
    func textFieldDidChange(textField: UITextField){
        textIsChange = true
    }
    
    @IBAction func postButton(_ sender: Any) {
        if tagTextField.text != ""{
            Database.database().reference().child("tags").observeSingleEvent(of: .value, with:{ snapshot in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                    for snap in snapshots {
                        
                        if let dictionary = snap.value as? Dictionary<String, AnyObject> {
                            
                            if self.tagTextField.text == dictionary["text"] as? String{
                                let alertController = UIAlertController(title: "Error", message: "Such tag already exists", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                return
                            }
                            
                            
                        }
                        
                    }
                    
                    
                }
                let tagRef = Database.database().reference().child("tags").childByAutoId()
                tagRef.setValue(["text":self.tagTextField.text])
                self.tagTextField.text = ""
                self.tagTableView.reloadData()
                // self.tagTableView.reloadData()
                
            })
           
            
            
            
        }
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textIsFirstUpdate {
            self.tagTextField.text = ""
            textIsFirstUpdate = false
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.textAlignment = .left
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }
    // text options
    func registerKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotification(){
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
        
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        let userInfo = notification.userInfo
        let keyboardFrameSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrameSize.height)
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentOffset = CGPoint.zero
    }
    
    
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        tagTextField.resignFirstResponder()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tagTextField.resignFirstResponder()
        
        return true
    }
    
    deinit {
        removeKeyboardNotification()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        let alertController = UIAlertController(title: "Change tag", message: "Please enter new tag", preferredStyle: .alert)
        alertController.textFields?.first?.text = tag
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text
            {
                Database.database().reference().child("tags").observeSingleEvent(of: .value, with:{ snapshot in
                    if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                        for snap in snapshots {
                            
                            if let dictionary = snap.value as? Dictionary<String, AnyObject> {
                                
                                if tag == dictionary["text"] as? String{
                                    Database.database().reference().child("tags").child(snap.key).updateChildValues(["text":text])
                                    self.tagTableView.reloadData()
                                }
                                
                                
                            }
                        }
                        
                    }
                    
                    // self.tagTableView.reloadData()
                    
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = tag
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
extension TagEditViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedTags = tags.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tagTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tagTableView.reloadData()
    }
    
}



