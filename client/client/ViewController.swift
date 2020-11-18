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
        
        if (UserDefaults.standard.object(forKey: User.token) != nil) {
            // auto login the user since this user's token is stored
            self.verifyAuthentication()
        }
    }
    
    func verifyAuthentication() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        AF.request(APIs.verifyAuthentication, method: .post, parameters: nil, headers: headers).responseJSON { [self] response in
            switch response.response?.statusCode {
                case 200?:
                    // the user is logged in with a valid token, so go straight to the dashboard
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let dashboardVC = storyboard.instantiateViewController(withIdentifier: "Dashboard") as! DashboardViewController
                    self.navigationController?.pushViewController(dashboardVC, animated: true)
                    break
                default:
                    // this user does not have a valid token, so remove the token and load the landing page normally
                    UserDefaults.standard.removeObject(forKey: User.token)
                    break
            }
        }
    }
    
}
extension UIColor {
    static let systemBlue = UIColor(red: 150/255, green: 59/255, blue: 48/255, alpha: 1)
}



