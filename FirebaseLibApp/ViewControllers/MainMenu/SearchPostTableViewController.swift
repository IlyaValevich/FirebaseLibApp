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
        print("Feed")
        super.viewDidLoad()
        
        DataService.dataService.POST_REF.observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
           
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data){

                    tempPosts.insert(post, at: 0)
                }
            }
            
            self.postList.insert(contentsOf: tempPosts, at: 0)
            
    
            
        })
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
