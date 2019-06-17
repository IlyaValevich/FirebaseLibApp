//
//  UserProfileSettingsViewController.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/11/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class UserProfileSettingsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    
    var user:UserProfile!
    
    var modelController: UserController!
    
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var imagePicker:UIImagePickerController!
    
    var imageIsChange: Bool = false
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerKeyboardNotification()
        
        userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
        userProfileImage.clipsToBounds = true
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        userProfileImage.isUserInteractionEnabled = true
        userProfileImage.addGestureRecognizer(imageTap)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.user = modelController.userModel
        
        self.nameTextField.text = user.name
        self.surnameTextField.text = user.surname
        self.userProfileImage.image = nil
        
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.userProfileImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
        
        activityView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        activityView.style = .whiteLarge
        activityView.color = .blue
        activityView.backgroundColor = .init(displayP3Red: 156, green: 123, blue: 162, alpha: 0.5)
        activityView.layer.cornerRadius = 10
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        view.addSubview(activityView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let userModel = modelController
        userModel?.userModel = self.user
        if modelController.isChange {
            self.nameTextField.text = user.name
            self.surnameTextField.text =  user.surname
            
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
    
    
    
    @IBAction func saveAction(_ sender: Any) {
        activityView.startAnimating()
        if (user.name != self.nameTextField.text! ||
            user.surname != self.surnameTextField.text! || self.imageIsChange ){
            user.name = self.nameTextField.text!
            user.surname = self.surnameTextField.text!
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let storageRef = Storage.storage().reference().child("user/\(uid)")
            if imageIsChange {
                guard let imageData = self.userProfileImage.image!.jpegData(compressionQuality: 0.75) else { return }
                
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                
                storageRef.putData(imageData, metadata: metaData) { metaData, error in
                    if error == nil, metaData != nil {
                        storageRef.downloadURL { url, error in
                            if url != nil {
                                guard let uid = Auth.auth().currentUser?.uid else { return }
                                let databaseRef = Database.database().reference().child("users").child(uid)
                                
                                let userObject = [
                                    "name": self.nameTextField.text!,
                                    "surname": self.surnameTextField.text!,
                                    "photoURL": url!.absoluteString
                                    ] as [String:Any]
                                
                                databaseRef.updateChildValues(userObject)
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.nameTextField.text! + self.surnameTextField.text!
                                changeRequest?.photoURL = url
                                
                                self.user.photoURL = url!
                                self.modelController.userModel = self.user
                                
                                self.activityView.stopAnimating()
                                
                                changeRequest?.commitChanges { error in
                                    if error == nil {
                                        print("User display name changed!")
                                        
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else{
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let databaseRef = Database.database().reference().child("users").child(uid)
                
                let userObject = [
                    "name": self.nameTextField.text!,
                    "surname": self.surnameTextField.text!
                    ] as [String:Any]
                
                databaseRef.updateChildValues(userObject)
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = self.nameTextField.text! + self.surnameTextField.text!
                //changeRequest?.photoURL = url
                self.activityView.stopAnimating()
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
            }
        }else{
            activityView.stopAnimating()
            
            let alertController = UIAlertController(title: "Error", message: "You don't change profile", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
        scrollView.contentOffset = CGPoint(x: 0, y: 100)
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentOffset = CGPoint.zero
    }
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        surnameTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        surnameTextField.resignFirstResponder()
        return true
    }
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
}
extension UserProfileSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userProfileImage.image = pickedImage
            self.imageIsChange = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

