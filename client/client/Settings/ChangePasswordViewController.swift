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
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 6
        oldPassword.layer.borderWidth = 2
        newPassword.layer.borderWidth = 2
        confirmPassword.layer.borderWidth = 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func updatePassword() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "password": newPassword.text!, "confirm_password": confirmPassword.text!, "old_password": oldPassword.text! ] as [String : Any]
        
        AF.request(APIs.settings, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if (response.value as! NSDictionary?) != nil {
                            self.navigationController?.popViewController(animated: true)
                        }
                        break
                    case 422?:
                        if let json = response.value {
                            let errorMessage: String? = ResponseSerializer.getErrorMessage(json: json)
                            
                            // create an alert that notifies the user they need to input a password
                            let alert = UIAlertController(title: "Invalid password", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
                        }
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
    
    @IBAction func savePressed(_ sender: Any) {
        if (newPassword.text!.count == 0 && confirmPassword.text!.count == 0) {
            // create an alert that notifies the user they need to input a password
            let alert = UIAlertController(title: "Invalid password input", message: "You must input your new password.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        } else if (newPassword.text != confirmPassword.text) {
            // create an alert that notifies the user their passwords must match
            let alert = UIAlertController(title: "Passwords do not match", message: "Your passwords must match.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            updatePassword()
        }
    }
    
}
