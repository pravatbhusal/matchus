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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.image = UIImage(named: "logo")
        // appleLogo.image = UIImage(named: "appleLogo")

        //loginButton Style
        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.systemBlue.cgColor
 
        //registerButton Style
        registerButton.layer.cornerRadius = 6
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
}
extension UIColor {
    static let systemBlue = UIColor(red: 150/255, green: 59/255, blue: 48/255, alpha: 1)
}



