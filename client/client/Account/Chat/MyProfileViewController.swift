//
//  MyProfileViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {

    @IBOutlet weak var settingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingButton.layer.cornerRadius = 6
        settingButton.layer.borderWidth = 2
    }

}
