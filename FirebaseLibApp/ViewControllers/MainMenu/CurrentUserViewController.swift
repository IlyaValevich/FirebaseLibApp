//
//  CurrentUserViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/26/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import Firebase

import UIKit

class CurrenUserViewController : UIViewController {
    @IBOutlet weak var myImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    var ref = DatabaseReference.init()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(CurrenUserViewController.openGallery(tapGesture:)))
        myImageView.isUserInteractionEnabled = true
        myImageView.addGestureRecognizer(tapGesture)
        
        /* self.getAllFIRData()*/
    }
    
    @objc func openGallery (tapGesture: UITapGestureRecognizer){
        self.setupImagePicker()
    }
    
    
    @IBAction func btnSaveClick(_ sender: UIButton) {
        self.saveFIRDate()
        //self.getAllFIRData()
        
    }
    
    func saveFIRDate(){
        self.uploadImage(self.myImageView.image!) { url in
            self.saveImage(profileURL: url!){ success in
                if success != nil{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    func uploadImage(_ image:UIImage, completion: @escaping ((_ url: URL?) -> ())){
        let storageRef = Storage.storage().reference().child("myimage.png")
        let imgData = myImageView.image?.pngData()
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        storageRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            if error == nil{
                print("success")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url)
                })
            }else{
                print("error in save image")
                completion(nil)
            }
        }
    }
    func saveImage (profileURL:URL, completion: @escaping ((_ url: URL?) -> ())){
        let dict = ["profileURL":profileURL.absoluteString] as [String: Any]
        self.ref.child("chat").childByAutoId().setValue(dict)
    }
}

extension CurrenUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func setupImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        myImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}

