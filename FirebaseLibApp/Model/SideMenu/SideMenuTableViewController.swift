import UIKit
import Firebase
import UIKit
class SideMenuTableViewController: UITableViewController {
    
    var optionsList = [Option]()
    var isAdmin = false
    var currentUsername = ""
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var userProfileImage: UIImageView!
    
    @IBOutlet weak var currentUserView: UIView!
    
    var modelController: UserController!
    
    var user : UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //standard data upload
        userProfileImage.layer.cornerRadius = userProfileImage.bounds.height / 2
        userProfileImage.clipsToBounds = true
        user = UserService.currentUserProfile!
        self.refreshControl = nil
        
        self.username.text = user.name + " " + user.surname
        self.userEmail.text = user.mail
        self.isAdmin = user.isAdmin
        self.userProfileImage.image = nil
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.userProfileImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
  
        
        let  tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        currentUserView.addGestureRecognizer(tap)
        
        //upload table
        
        // optionsList.append(Option(textOption: "New Post", imageOption: UIImage(named: "bookIcon")!))
        
        //mb first subs?
        
        optionsList.insert(Option(textOption: "Settings Profile", imageOption: UIImage(named: "optionIcon")!), at: 0)
        optionsList.insert(Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!), at: 1)
        
        //admin acc login:ilya.valevich@gmail.com  pass:qwerty
        
        if self.isAdmin == true {
            optionsList.insert(Option(textOption: "Tag Edit", imageOption: UIImage(named: "tagIcon")!), at: 2)
            optionsList.insert(Option(textOption: "Users Edit", imageOption: UIImage(named: "usersIcon2")!), at: 3)
            
        }
        
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // if we have update
        super.viewWillAppear(animated)
        user = UserService.currentUserProfile!
        
        self.username.text = user.name + " " + user.surname
        self.userEmail.text = user.mail
        self.userProfileImage.image = nil
        ImageService.getImage(withURL: user.photoURL ) { image, url in
            guard let _user = self.user else { return }
            if _user.photoURL.absoluteString == url.absoluteString {
                self.userProfileImage.image = image
            } else {
                print("Not the right image")
            }
            
        }
        self.tableView.reloadData()
        
     
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        //if tap on first cell
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = UserProfileViewController.makeUserProfileViewController(user: UserService.currentUserProfile!)
        vc.modelController = UserController()
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: def table method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
        
        switch indexPath.row {
        // case 0: NotificationCenter.default.post(name: NSNotification.Name("toNewPost"), object: nil)
        case 0: NotificationCenter.default.post(name: NSNotification.Name("toSettings"), object: nil)
        case 1: NotificationCenter.default.post(name: NSNotification.Name("toLoginScreen"), object: nil)
        case 2: NotificationCenter.default.post(name: NSNotification.Name("toTagEdit"), object: nil)
        case 3: NotificationCenter.default.post(name: NSNotification.Name("toUsersEdit"), object: nil)
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = optionsList[indexPath.row]
        
        //we are using a custom cell
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableViewCell") as? SideMenuTableViewCell {
            
            cell.configureCell(option: option )
            
            return cell
            
        } else {
            print("cell fail")
            return SideMenuTableViewCell()
            
        }
    }
}



//override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    print(indexPath.row)
//    
//    NotificationCenter.default.post(name: NSNotification.Name("ToggleSideMenu"), object: nil)
//    if self.isAdmin != true{
//        switch indexPath.row {
//        case 0: NotificationCenter.default.post(name: NSNotification.Name("toSettings"), object: nil)
//        case 1: NotificationCenter.default.post(name: NSNotification.Name("toLoginScreen"), object: nil)
//            
//            
//        default: break
//        }
//    }
//    else{
//        switch indexPath.row {
//        case 0: NotificationCenter.default.post(name: NSNotification.Name("toSettings"), object: nil)
//        case 1: NotificationCenter.default.post(name: NSNotification.Name("toTagEdit"), object: nil)
//        case 2: NotificationCenter.default.post(name: NSNotification.Name("toUsersEdit"), object: nil)
//            
//        case 3: NotificationCenter.default.post(name: NSNotification.Name("toLoginScreen"), object: nil)
//        default: break
//        }
//    }
//}
//
//@IBAction func refreshController(_ sender: Any) {
//    
//    let name = DataService.dataService.CURRENT_USER_REF.observe(DataEventType.value, with: { (snapshot) in
//        let value = snapshot.value as? NSDictionary
//        self.username.text = (value?["name"] as? String)! + " " + (value?["surname"] as? String)!
//        self.userEmail.text = value?["mail"] as? String ?? ""
//        self.isAdmin = value?["isAdmin"] as? Bool ?? false
//        self.optionsList.removeAll()
//        self.optionsList.insert(Option(textOption: "Settings", imageOption: UIImage(named: "optionIcon")!), at: 0)
//        self.optionsList.insert(Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!), at: 1)
//        self.isAdmin = value?["isAdmin"]! as! Bool
//        if self.isAdmin == true {
//            self.optionsList.remove(at: 1)
//            self.optionsList.insert(Option(textOption: "Tag Edit", imageOption: UIImage(named: "tagIcon")!), at: 1)
//            self.optionsList.insert(Option(textOption: "Users Edit", imageOption: UIImage(named: "usersIcon")!), at: 2)
//            self.optionsList.insert(Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!), at: 3)
//        }
//        self.refreshControl?.endRefreshing()
//        self.tableView.reloadData()
//    }){ (error) in
//        print(error.localizedDescription)
//    }
//    
//    ImageService.getImage(withURL: (Auth.auth().currentUser?.photoURL)!) { image, url in
//        self.userProfileImage.image = image
//        print("image download")
//    }
//    
//}
//
//@objc func handleTap(sender: UITapGestureRecognizer? = nil) {
//    
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let vc = UserProfileViewController.makeUserProfileViewController(user: UserService.currentUserProfile!)
//    vc.modelController = ModelController()
//    
//    self.present(vc, animated: true, completion: nil)
//}
//let name = DataService.dataService.CURRENT_USER_REF.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//    let value = snapshot.value as? NSDictionary
//    self.username.text = (value?["name"] as? String)! + " " + (value?["surname"] as? String)!
//    self.userEmail.text = value?["mail"] as? String ?? ""
//    
//    self.optionsList.insert(Option(textOption: "Settings", imageOption: UIImage(named: "optionIcon")!), at: 0)
//    self.optionsList.insert(Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!), at: 1)
//    self.isAdmin = value?["isAdmin"]! as! Bool
//    if self.isAdmin == true {
//        self.optionsList.remove(at: 1)
//        self.optionsList.insert(Option(textOption: "Tag Edit", imageOption: UIImage(named: "tagIcon")!), at: 1)
//        self.optionsList.insert(Option(textOption: "Users Edit", imageOption: UIImage(named: "usersIcon")!), at: 2)
//        self.optionsList.insert(Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!), at: 3)
//    }
//    self.tableView.reloadData()
//}){ (error) in
//    print(error.localizedDescription)
//}

//    @IBAction func refreshController(_ sender: Any) {
//
//        // self.optionsList[0] = Option(textOption: "New Post", imageOption: UIImage(named: "bookIcon")!)
//        self.optionsList[0] = Option(textOption: "Settings", imageOption: UIImage(named: "optionIcon")!)
//        self.optionsList[1] = Option(textOption: "Log Out", imageOption: UIImage(named: "logoutIcon")!)
//
//        if self.isAdmin == true {
//            self.optionsList[2] = Option(textOption: "Tag Edit", imageOption: UIImage(named: "tagIcon")!)
//
//        }

//        DataService.dataService.userID  = Auth.auth().currentUser?.uid
//        let name = DataService.dataService.CURRENT_USER_REF.observe(DataEventType.value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            self.username.text = (value?["name"] as? String)! + " " + (value?["surname"] as? String)!
//            self.userEmail.text = value?["email"] as? String ?? ""
//            self.isAdmin = value?["isAdmin"] as? Bool ?? false
//        }){ (error) in
//            print(error.localizedDescription)
//        }
//
//        ImageService.getImage(withURL: (Auth.auth().currentUser?.photoURL)!) { image, url in
//            self.userProfileImage.image = image
//            print("image download")
//        }
//
//        self.refreshControl?.endRefreshing()
//        self.tableView.reloadData()
//    }
//
