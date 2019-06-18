//
//  SignUpViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/6/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //MARK -
    @IBOutlet weak internal var emailField: UITextField!
    @IBOutlet weak internal var userNameField: UITextField!
    @IBOutlet weak internal var userSurnameField: UITextField!
    @IBOutlet weak internal var passwordField: UITextField!
    @IBOutlet weak internal var confirmPasswordField: UITextField!
    @IBOutlet weak internal var imageProfileView:UIImageView!
    
    @IBOutlet weak var cancelButton: UIButton!
  //  @IBOutlet weak var tapToChangLabel: UILabel!
  //  @IBOutlet weak var retypePasswordLabel: UILabel!
    //@IBOutlet weak var passwordLabel: UILabel!
  //  @IBOutlet weak var surnameLabel: UILabel!
 //   @IBOutlet weak var nameLabel: UILabel!
 //   @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak internal var continueButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var imagePicker: ImagePicker!
    
    var modelController: UserController!
    
    override internal func viewDidLoad(){
        super.viewDidLoad()
        registerKeyboardNotification()
        
        imageProfileView.layer.cornerRadius = imageProfileView.bounds.height / 2
        imageProfileView.clipsToBounds = true
        
//        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
//        imageProfileView.addGestureRecognizer(imageTap)
//        imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
        imageProfileView.isUserInteractionEnabled = true
        imageProfileView.addGestureRecognizer(imageTap)
        var imagePicker: ImagePicker!
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        
        
        activityView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        activityView.style = .whiteLarge
        activityView.color = .blue
        activityView.backgroundColor = .init(displayP3Red: 156, green: 123, blue: 162, alpha: 0.5)
        activityView.layer.cornerRadius = 10
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
        
        
        self.passwordField.isSecureTextEntry = true
        self.confirmPasswordField.isSecureTextEntry = true
        
        emailField.delegate = self
        userNameField.delegate = self
        passwordField.delegate = self
        userSurnameField.delegate = self
        confirmPasswordField.delegate = self
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
//        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
    }

    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.pickerController.allowsEditing = true
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func RegisterAction(_ sender: Any) {
        let email = emailField.text
        let pass = passwordField.text
        let name = userNameField.text
        let surname = userSurnameField.text
        let confirmPassword = confirmPasswordField.text
        let image = imageProfileView.image!
        
        self.continueButton.isEnabled = true
        
        if email == "" && pass == "" && name == "" && surname == "" && confirmPassword == "" {
            let alertController = UIAlertController(title: "No registration data", message: "Please  fill in the fields", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            if passwordField.text !=  confirmPasswordField.text {
                let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                
                
                
                // self.scrollView.isHidden = true
                
                Auth.auth().createUser(withEmail: email!, password: pass!) { user, error in
                    if error == nil && user != nil {
                        print("User created!")
                    }
                    
                    self.activityView.startAnimating()
                    
                    // 1. Upload the profile image to Firebase Storage
                    
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    let storageRef = Storage.storage().reference().child("user/\(uid)")
                    
                    guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
                    
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpg"
                    
                    storageRef.putData(imageData, metadata: metaData) { metaData, error in
                        if error == nil, metaData != nil {
                            storageRef.downloadURL { url, error in
                                if url != nil {
                                    guard let uid = Auth.auth().currentUser?.uid else { return }
                                    let databaseRef = Database.database().reference().child("users").child(uid)
                                    
                                    let userObject = [
                                        "name": name,
                                        "surname": surname,
                                        "photoURL": url!.absoluteString,
                                        "mail": email,
                                        "isAdmin": false
                                        ] as [String:Any]
                                    
                                    databaseRef.setValue(userObject)
                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changeRequest?.displayName = name! + surname!
                                    changeRequest?.photoURL = url
                                    self.activityView.stopAnimating()
                                    changeRequest?.commitChanges { error in
                                        if error == nil {
                                            print("User display name changed!")
                                            self.dismiss(animated: true, completion: nil)
                                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                            appDelegate.openViewController()
                                            //                                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                            //                                            let newViewController = storyBoard.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
                                            //                                            self.present(newViewController, animated: true, completion: nil)
                                            //                                            self.dismiss(animated: false, completion: nil)
                                            
                                        }
                                        else{
                                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                            
                                            alertController.addAction(defaultAction)
                                            self.present(alertController, animated: true, completion: nil)
                                        }
                                    }
                                }
                                else{
                                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                            
                        }else{
                            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                    
                    
                    
                    
                }
            }
        }
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
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrameSize.height - 200)
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentOffset = CGPoint.zero
    }
    
    
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        userNameField.resignFirstResponder()
        userSurnameField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        userNameField.resignFirstResponder()
        userSurnameField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        return true
    }
    
    func saveProfile(name:String,surname:String, profileImageURL:URL,mail:String,isAdmin:Bool, completion: @escaping ((_ success:Bool)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users").child(uid)
        
        let userObject = [
            "name": name,
            "surname": surname,
            "photoURL": profileImageURL.absoluteString,
            "mail": mail,
            "isAdmin": isAdmin
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }
    
    func resetForm() {
        let alert = UIAlertController(title: "Error signing up", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                }
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    
    
}
extension SignUpViewController: ImagePickerDelegate {
    
    
    func didSelect(image: UIImage?) {
        self.imageProfileView.image = image
    }
}

