//
//  ChangePasswordViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordViewController: UIViewController {
    
    var oldPassword: String!
    var newPassword: String!
    var confirmPassword: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func updatePassword() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "password": newPassword!, "confirm_password": confirmPassword!, "old_password": oldPassword! ] as [String : Any]
        
        AF.request(APIs.settings, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value as! NSDictionary? {
                            print(json)
                        }
                        break
                    default:
                        // create a failure to update password alert
                        let alert = UIAlertController(title: "Failed to Update Password", message: "Could not update password, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
}
