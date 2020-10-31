//
//  StatusBarViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class StatusBarViewController: UIViewController {

    @IBOutlet weak var plusButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.layer.cornerRadius = 18
    }

}
