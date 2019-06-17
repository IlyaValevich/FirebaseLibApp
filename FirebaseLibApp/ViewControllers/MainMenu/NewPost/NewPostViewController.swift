//
//  NewPostViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/8/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
protocol NewPostVCDelegate {
    func didUploadPost(withID id:String)
}

class NewPostViewController:UIViewController, UITextViewDelegate, UITextFieldDelegate{
    fileprivate let tagsField = WSTagsField()
    
    @IBOutlet fileprivate weak var tagsView: UIView!
    
    @IBOutlet weak var textView:UITextView!
    @IBOutlet weak var bookName:UITextField!
    @IBOutlet weak var bookAuthorName:UITextField!
    @IBOutlet weak var authorVotes:CosmosView!
    @IBOutlet weak var postImageView:UIImageView!
    
    var delegate:NewPostVCDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tapToChangeButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    var post:Post? = nil
    var tags:[String]!
    var imagePicker: ImagePicker!
    var firstUpdate = true
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var modelController: TagController! = TagController()
    var postController: PostController! = PostController()
    
    
    static func makeUserProfileViewController(post: Post) ->  NewPostViewController {
        
        let newViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        
        
        newViewController.post = post
        
        return newViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeyboardNotification()
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(showImagePicker))
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(imageTap)
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        
       // adjustUITextViewHeight(arg: textView )
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = true
        //textView.sizeToFit()
        
        //tag
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)
        //tagsField.translatesAutoresizingMaskIntoConstraints = false
        //tagsField.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
        tagsField.cornerRadius = 3.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10
        
        //tagsField.numberOfLines = 3
        //tagsField.maxHeight = 100.0
        
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 18, left: 10, bottom: 10, right: 10) //old padding

        tagsField.readOnly = !tagsField.readOnly
        //sender.isSelected = tagsField.readOnly
        tagsField.placeholder = "Enter a tag"
        tagsField.placeholderColor = .red
        tagsField.placeholderAlwaysVisible = true
        tagsField.backgroundColor = .lightGray
        tagsField.returnKeyType = .next
        tagsField.delimiter = ""
        tagsField.keyboardAppearance = .dark
        
        tagsField.textDelegate = self
        //tagsField.acceptTagOption = .space
        
        textFieldEvents()
        
        
        activityView.frame = CGRect(x: 0, y: 0, width: 100.0, height: 100.0)
        activityView.style = .whiteLarge
        activityView.color = .blue
        activityView.backgroundColor = .init(displayP3Red: 156, green: 123, blue: 162, alpha: 0.5)
        activityView.layer.cornerRadius = 10
        activityView.center = self.view.center
        activityView.hidesWhenStopped = true
        view.addSubview(activityView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        self.post = postController.postModel
        
        if(self.post != nil){
            
            tagsField.addTags(post!.tags)
            
        
            
            textView.text = post?.postText
            bookName.text = post?.postBookName
            bookAuthorName.text = post?.postBookAuthor
            authorVotes.rating = post!.postAuthorVotes
            postImageView.image = nil
            
            ImageService.getImage(withURL: post!.postImageURL) { image, url in
                guard let _post = self.post else { return }
                if _post.postImageURL.absoluteString == url.absoluteString {
                    self.postImageView.image = image
                } else {
                    print("Not the right image")
                }
                
            }
        }
        
    }
    @IBAction func showImagePicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tags = []
        self.tags = modelController.tags
        tagsField.addTags(tags)
         
       
    }
    
    @IBAction func handlePostButton() {
        guard let userProfile = UserService.currentUserProfile else
        { return }
        
        postButton.isEnabled = true
        
        var tagsId:[String] = []
        
        Database.database().reference().child("tags").observe(DataEventType.value, with: { snapshot in
        
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let tagDictionary = snap.value as? Dictionary<String, AnyObject> {
                        
                        let text = tagDictionary["text"] as? String
                        for i in self.tags{
                            if  i  == text{
                                tagsId.insert(snap.key, at: 0)
                            }
                        }
                        
                    }
                }
            }
        })
        print(tagsId)
        
        let postRef = Database.database().reference().child("posts").childByAutoId()
        self.uploadPostImage(image: postImageView.image!, uid: postRef.key! ) { url in
            
            if url != nil {
                let authorObject = [
                    "uid": userProfile.uid,
                    "name": userProfile.name,
                    "surname": userProfile.surname,
                    "mail": userProfile.mail,
                    "photoURL": userProfile.photoURL.absoluteString,
                    "isAdmin": userProfile.isAdmin
                    ] as [String : Any]

                let usersAppreciatedObject = [:] as [String : Any]
           
                let postObject = [
                    "author": authorObject,
                    "text": self.textView.text! ,
                    "bookName": self.bookName.text!,
                    "bookAuthor": self.bookAuthorName.text!,
                    "authorVotes": self.authorVotes.rating,/////!
                    "usersVotes": 0,
                    "imageURL": url?.absoluteString,
                    "tags": tagsId ,
                    "timestamp": [".sv":"timestamp"],
                    "usersAppreciated":usersAppreciatedObject
                    ] as [String : Any]
                
                postRef.setValue(postObject, withCompletionBlock: { error, ref in
                    if error == nil {
                        self.delegate?.didUploadPost(withID: ref.key!)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        textView.resignFirstResponder()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
            super.dismiss(animated: flag, completion: completion)
        })
    }
    
    func uploadPostImage(image:UIImage, uid:String, completion: @escaping ((_ url:URL?)->())) {
        let storageRef = Storage.storage().reference().child("posts/\(uid)")
        
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
    
    @IBAction func addTagsAction(_ sender: Any) {

        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TagViewController") as? TagViewController {
           // let model = TagController()

            viewController.modelController = modelController
            
            
            self.present(viewController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if firstUpdate {
            self.textView.text = ""
            firstUpdate = false
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
        textView.resignFirstResponder()
        bookName.resignFirstResponder()
        bookAuthorName.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.resignFirstResponder()
        bookName.resignFirstResponder()
        bookAuthorName.resignFirstResponder()
        
        return true
    }

    deinit {
        removeKeyboardNotification()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editVC = segue.destination as? TagViewController {
            editVC.modelController = modelController
        }
    }
}
extension NewPostViewController: ImagePickerDelegate {
    
     func didSelect(image: UIImage?) {
        self.postImageView.image = image
        tapToChangeButton.isHidden = true
    }
}
extension NewPostViewController {
    
    fileprivate func textFieldEvents() {
        tagsField.onDidAddTag = { field, tag in
            print("onDidAddTag", tag.text)
        }
        
        tagsField.onDidRemoveTag = { field, tag in
            print("onDidRemoveTag", tag.text)
        }
        
        tagsField.onDidChangeText = { _, text in
            print("onDidChangeText")
        }
        
        tagsField.onDidChangeHeightTo = { _, height in
            print("HeightTo \(height)")
        }
        
        tagsField.onDidSelectTagView = { _, tagView in
            print("Select \(tagView)")
        }
        
        tagsField.onDidUnselectTagView = { _, tagView in
            print("Unselect \(tagView)")
        }
    }
    
}

//extension NewPostViewController UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == tagsField {
//            anotherField.becomeFirstResponder()
//        }
//        return true
//    }
//
//}
