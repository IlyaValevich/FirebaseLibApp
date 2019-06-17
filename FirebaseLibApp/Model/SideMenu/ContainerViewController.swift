//
//  ContainerViewController.swift
//  firebaseapp
//
//  Created by Илья Валевич on 4/15/19.
//  Copyright © 2019 IlyaValevich. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    //usual sidebar with status, opens by shifting the view
    
    @IBOutlet weak var sideMenuConstraint: NSLayoutConstraint!
    var sideMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //add side menu
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleSideMenu),
                                               name: NSNotification.Name("ToggleSideMenu"),
                                               object: nil)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(openSideMenu))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(hideSideMenu))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
    }
    
    @objc func toggleSideMenu() {
        if sideMenuOpen {
            sideMenuOpen = false
            sideMenuConstraint.constant = -240
            
        } else {
            sideMenuOpen = true
            sideMenuConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func hideSideMenu() {
        
        sideMenuOpen = false
        sideMenuConstraint.constant = -240
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func openSideMenu() {
        
        
        sideMenuOpen = true
        sideMenuConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}
