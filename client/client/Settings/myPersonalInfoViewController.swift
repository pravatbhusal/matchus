//
//  myPersonalInfoViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class myPersonalInfoViewController: UIViewController {

    @IBOutlet weak var myNameLabel: UITextField!
    @IBOutlet weak var myLocationLabel: UITextField!
    @IBOutlet weak var myBioLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myNameLabel.layer.borderWidth = 2
        myLocationLabel.layer.borderWidth = 2
        myBioLabel.layer.borderWidth = 2
    }

}
