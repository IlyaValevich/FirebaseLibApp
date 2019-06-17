import Foundation
import UIKit
import Firebase
class FeedTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView:UITableView!
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    var posts = [Post]()
    
    var fetchingMore = false
    var endReached = false
    
    let leadingScreensForBatching:CGFloat = 3.0
    
    var refreshControl:UIRefreshControl!
    
    var lastUploadedPostID:String?
    
    var postsRef:DatabaseReference {
        return Database.database().reference().child("posts")
    }
    
    var oldPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let lastPost = posts.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = DataService.dataService.POST_REF.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp)
        } else {
            queryRef = DataService.dataService.POST_REF.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    var newPostsQuery:DatabaseQuery {
        var queryRef:DatabaseQuery
        let firstPost = posts.first
        if firstPost != nil {
            let firstTimestamp = firstPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = DataService.dataService.POST_REF.queryOrdered(byChild: "timestamp").queryStarting(atValue: firstTimestamp)
        } else {
            queryRef = DataService.dataService.POST_REF.queryOrdered(byChild: "timestamp")
        }
        return queryRef
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        
        let cellNib = UINib(nibName: "PostCellTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "postCell")
        tableView.register(LoadingCell.self, forCellReuseIdentifier: "loadingCell")
        tableView.backgroundColor = UIColor(white: 0.90,alpha:1.0)
        view.addSubview(tableView)
        
        var layoutGuide:UILayoutGuide!
        
        
        if #available(iOS 11.0, *) {
            layoutGuide = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
            layoutGuide = view.layoutMarginsGuide
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        refreshControl = UIRefreshControl()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            // Fallback on earlier versions
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        let newPostButton = UIButton(frame: CGRect(x: self.view.frame.size.width - 60, y: self.view.frame.size.height - 110, width: 50, height: 50))
        newPostButton.backgroundColor = .green
        newPostButton.layer.cornerRadius = newPostButton.bounds.height / 2
        newPostButton.clipsToBounds = true
        //newPostButton.setTitle("", for: .normal)
        let image = UIImage(named: "newPostIcon") as! UIImage
        newPostButton.setBackgroundImage(image, for: UIControl.State.normal)
        newPostButton.addTarget(self, action: #selector(newPostAction), for: .touchUpInside)
        self.view.addSubview(newPostButton)
        
        beginBatchFetch()
       

        
        
           // let overlayImage = self.faceOverlayImageFrom(self.image)
            
            // 2
       
                // 3
                //self?.fadeInNewImage(overlayImage)
        
        //let syncConc = DispatchQueue(label:"con",attributes:.concurrent)
        //syncConc.sync {
//        let id = ["-LensPXBQI-qrawQ48X7","-LensQHMyeTC8a47ZRwl"]
//            var tagList:[Tag] = []
//            var ref: DatabaseReference!
//            ref = Database.database().reference()
//            for i in id{
//                ref.child("tags").child(i).observeSingleEvent(of: .value, with: { (snapshot) in
//                    let dictionary = snapshot.value as? [String : AnyObject]
//
//                    let queue = DispatchQueue(label: "com.tursunov.app.exampleQueue")
//
//                    queue.async {
//                        // ...
//                        DispatchQueue.main.sync { // there's no deadlock
//                            // ...
//
//                        let tag = Tag(id: i, text: dictionary!["text"] as! String)
//                    tagList.append(tag)
//                        }
//                        print(tagList)
//                    }
//                }, withCancel: nil)
//
//
//        }
//
            }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        listenForNewPosts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopListeningForNewPosts()
    }
    
    @objc func handleRefresh() {
        print("Refresh!")
        
        //toggleSeeNewPostsButton(hidden: true)
        
        newPostsQuery.queryLimited(toFirst: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            let firstPost = self.posts.first
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    childSnapshot.key != firstPost?.id {
                    
                    tempPosts.insert(post, at: 0)
                }
            }
            
            self.posts.insert(contentsOf: tempPosts, at: 0)
            
            let newIndexPaths = (0..<tempPosts.count).map { i in
                return IndexPath(row: i, section: 0)
            }
            
            self.refreshControl.endRefreshing()
            self.tableView.insertRows(at: newIndexPaths, with: .top)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.listenForNewPosts()
            
        })
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()) {
        
        oldPostsQuery.queryLimited(toLast: 20).observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            let lastPost = self.posts.last
            for child in snapshot.children {
                print(snapshot)
                if let childSnapshot = child as? DataSnapshot,
                    let data = childSnapshot.value as? [String:Any],
                    let post = Post.parse(childSnapshot.key, data),
                    childSnapshot.key != lastPost?.id {
                    
                    tempPosts.insert(post, at: 0)
                }
            }
          
            return completion(tempPosts)
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return posts.count
        case 1:
            return fetchingMore ? 1 : 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCellTableViewCell
            cell.set(post: posts[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! LoadingCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 72.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = PostViewController.makePostViewController(post: post)
        vc.modelController = PostController()
        self.present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        self.tableView.reloadSections(IndexSet(integer: 1), with: .fade)
        
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.listenForNewPosts()
            }
        }
    }
    
    var postListenerHandle:UInt?
    
    func listenForNewPosts() {
        
        guard !fetchingMore else { return }
        
        // Avoiding duplicate listeners
        stopListeningForNewPosts()
        
        postListenerHandle = newPostsQuery.observe(.childAdded, with: { snapshot in
            
            if snapshot.key != self.posts.first?.id,
                let data = snapshot.value as? [String:Any],
                let post = Post.parse(snapshot.key, data) {
                
                self.stopListeningForNewPosts()
                
                if snapshot.key == self.lastUploadedPostID {
                    self.handleRefresh()
                    self.lastUploadedPostID = nil
                } //else {
                //  self.toggleSeeNewPostsButton(hidden: false)
                // }
            }
        })
    }
    
    func stopListeningForNewPosts() {
        if let handle = postListenerHandle {
            newPostsQuery.removeObserver(withHandle: handle)
            postListenerHandle = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPostNavBar = segue.destination as? UINavigationController,
            let newPostVC = newPostNavBar.viewControllers[0] as? NewPostViewController {
            
            newPostVC.delegate = self
        }
    }
    
    @objc func newPostAction(){
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let viewController = mainStoryboard.instantiateViewController(withIdentifier: "NewPostViewController") as? NewPostViewController{
            self.present(viewController, animated: true, completion: nil)}
    }
}

extension FeedTableViewController: NewPostVCDelegate {
    func didUploadPost(withID id: String) {
        self.lastUploadedPostID = id
    }
}
