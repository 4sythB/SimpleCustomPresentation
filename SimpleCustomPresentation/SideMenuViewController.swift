//
//  SideMenuViewController.swift
//  SimpleCustomPresentation
//
//  Created by Brad Forsyth on 3/14/18.
//  Copyright © 2018 Bloom Built Inc. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    
    class func createFromStoryboard() -> SideMenuViewController {
        let storyboard = UIStoryboard(name: "SideMenu", bundle: nil)
        let sideMenuVC = storyboard.instantiateInitialViewController() as! SideMenuViewController
        sideMenuVC.modalPresentationStyle = .custom
        
        return sideMenuVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .blue
    }
}
