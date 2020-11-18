//
//  MyProfileViewController.swift
//  Matchus
//
//  Created by promazo on 11/17/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderWidth = 2
    }
}
