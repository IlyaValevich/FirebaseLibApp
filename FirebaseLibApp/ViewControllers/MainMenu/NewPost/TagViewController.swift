//
//  TagEditViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/24/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//


import Firebase
import UIKit



class TagViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    struct Tag {
        var text:String
        var isSelect:Bool
        init(text:String, isSelect:Bool) {
            self.text = text;
            self.isSelect = isSelect;
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tagTableView: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    

    var tags = [Tag]()
    
    var searchedTags = [Tag]()
    
    var searching = false
    
    var activityView:UIActivityIndicatorView! = UIActivityIndicatorView()
    
    var textIsChange = false
    
    var textIsFirstUpdate = true
    
    var modelController: TagController!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tagTableView.delegate = self
        tagTableView.dataSource = self
        
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
                        
                        self.tags.insert(Tag(text: text!,isSelect: false), at: 0)
                    }
                }
            }
            
            //check select tags
            for i in 0..<self.tags.count{
                for j in self.modelController.tags{
                    if self.tags[i].text == j{
                        self.tags[i].isSelect = true
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
        return searchedTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tag = searchedTags[indexPath.row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell") as? TagTableViewCell {
            
            cell.set(tag: tag.text)
            if tag.isSelect{
                cell.tagSelectImage.image = UIImage(named: "selectIcon")
            }else{
                cell.tagSelectImage.image = UIImage(named: "unselectIcon")
            }
            
            return cell
            
        } else {
            print("cell fail")
            return UserTableViewCell()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tag = searchedTags[indexPath.row]
        let someIndexPath: NSIndexPath = tableView.indexPathForSelectedRow! as NSIndexPath
        let cell: TagTableViewCell = tableView.cellForRow(at: someIndexPath as IndexPath) as! TagTableViewCell
        
        if cell.isSelected{
            tag.isSelect = !tag.isSelect
            if tag.isSelect{
                 cell.tagSelectImage.image = UIImage(named: "selectIcon")
            }
            else{
                 cell.tagSelectImage.image = UIImage(named: "unselectIcon")
            }
            tableView.deselectRow(at: someIndexPath as IndexPath, animated: true)
        }
        
        self.searchedTags[indexPath.row].isSelect = tag.isSelect
        //update one tag in main tags
        if let indexUpdateTag = self.tags.firstIndex(where: {$0.text == tag.text}){
            self.tags[indexUpdateTag].isSelect = tag.isSelect
        }

    }
    

    @IBAction func AddTagButton(_ sender: Any) {
        
        var bufTag = [String]()
        for i in self.tags {
            if i.isSelect {
                bufTag.append(i.text)
            }
        }
        
        modelController.tags = bufTag
        print(modelController.tags)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension TagViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchedTags)
        searchedTags = tags.filter({$0.text.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        print(searchedTags)
        tagTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tagTableView.reloadData()
    }
    
}




