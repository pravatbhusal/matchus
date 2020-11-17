//
//  MyProfileViewController.swift
//  Matchus
//
//  Created by promazo on 11/17/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderWidth = 2
    }

}
