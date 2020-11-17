//
//  ViewController.swift
//  client
//
//  Created by pbhusal on 10/5/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    let dashboardSegueIdentifier: String = "DashboardSegueIdentifier"
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loginButton Style
        loginButton.layer.cornerRadius = 6
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.systemBlue.cgColor
 
        // registerButton Style
        registerButton.layer.cornerRadius = 6
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        autoLogin()
    }
    
    func autoLogin() {
        // TODO: actually get this to work
        if (UserDefaults.standard.object(forKey: User.token) != nil) {
            print("auto login")
        }
    }
    
}
extension UIColor {
    static let systemBlue = UIColor(red: 150/255, green: 59/255, blue: 48/255, alpha: 1)
}



