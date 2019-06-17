//
//  MenuLoginViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 3/19/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
class MenuLoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signupButton:UIButton!
    
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotification()
    
        
        activityView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        activityView.style = .whiteLarge
        activityView.color = .blue
        activityView.backgroundColor = .init(displayP3Red: 156, green: 123, blue: 162, alpha: 0.5)
        activityView.layer.cornerRadius = 10
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
    
        
        self.passwordField.isSecureTextEntry = true
        
        
        
        emailField.delegate = self
        passwordField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
 
    
    deinit {
        removeKeyboardNotification()
    }
    
    @IBAction func handleSignIn() {
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        activityView.startAnimating()
        Auth.auth().signIn(withEmail: email, password: pass) {user, error in
            if error == nil && user != nil {
                self.dismiss(animated: true, completion: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.openViewController()
               // self.dismiss(animated: true, completion: nil)
            } else {
                self.activityView.stopAnimating()
                print("Error logging in: \(error!.localizedDescription)")
                let alertController = UIAlertController(title: "Incorrect", message: "Error logging in: \(error!.localizedDescription)", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                
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
        scrollView.contentOffset = CGPoint(x: 0, y: keyboardFrameSize.height - 100)
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        scrollView.contentOffset = CGPoint.zero
    }

    @objc func tap(gesture: UITapGestureRecognizer) {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return true
    }
    
}
