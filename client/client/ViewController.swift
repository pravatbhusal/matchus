//
//  ViewController.swift
//  client
//
//  Created by pbhusal on 10/5/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var appleLogo: UIImageView!
    @IBOutlet weak var loginStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.image = UIImage(named: "logo")
//        appleLogo.image = UIImage(named: "appleLogo")
        
        //loginButton Style
        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor.red.cgColor

        //registerButton Style
        registerButton.layer.cornerRadius = 6
    }
    
}



