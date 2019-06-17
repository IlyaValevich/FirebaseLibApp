//
//  SearchPostTableViewController.swift
//  FirebaseLibApp
//
//  Created by Илья Валевич on 5/16/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit
import Firebase
class SearchPostTableViewController:  UITableViewController{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var postList = [Post]()
    var searchedPostList = [Post]()
    var searching = false
    override func viewDidLoad() {
       
        super.viewDidLoad()
        let cellNib = UINib(nibName: "PostCellTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)
        
        loadNewPost{ success in
            if success{
                self.searchedPostList = self.postList
            self.tableView.reloadData()
                
              
            }
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPostList.count // return the total items in the items array
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCellTableViewCell
                cell.set(post: postList[indexPath.row])
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
                cell.spinner.startAnimating()
                return cell
            }
    }
    func loadNewPost(completion: @escaping (Bool) -> ()){
        
        
        let postsRef = Database.database().reference().child("posts")
        
        self.postList = []
        
        postsRef.observe(DataEventType.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let id = snap.key
                        let dateNow = Calendar.current.date(byAdding: .day, value: -7, to: Date())
                        let post =  Post.parse(id, postDictionary)
                        self.postList.insert(post!, at: 0)
                    }
                }
                completion(true)
            }
        })
    }
}
extension SearchPostTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count > 0){
            searchedPostList = postList.filter({$0.author.name.lowercased().prefix(searchText.count) + $0.author.surname.lowercased().prefix(searchText.count) == searchText.lowercased()})
            //print(searchedPostList)
            searching = true
            tableView.reloadData()
        }
        else{
            searchedPostList = []
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
}
