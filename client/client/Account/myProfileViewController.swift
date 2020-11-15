//
//  myProfileViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class myProfileViewController: UIViewController {

    @IBOutlet weak var settingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        settingButton.layer.cornerRadius = 6
        settingButton.layer.borderWidth = 2
        
    }

}
