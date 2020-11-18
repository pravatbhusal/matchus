//
//  AccountSettingsViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class AccountSettingsViewController: UIViewController {
    @IBOutlet weak var emailAddressLabel: UITextField!
    
    var interestsList: [String]!
    
    @IBOutlet weak var changePassword: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    
    var email: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailAddressLabel.layer.borderWidth = 2
        saveButton.layer.cornerRadius = 6
        changePassword.layer.cornerRadius = 6
        
        loadEmail()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func loadEmail() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value as! NSDictionary? {
                        self.email = ResponseSerializer.getProfileEmail(json: json)
                        self.emailField.text = self.email
                     }
                     break
            default:
                // create a failure to load email alert
                let alert = UIAlertController(title: "Failed to Load Email", message: "Could not load your profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func updateEmail() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "email": emailField.text! ] as [String : Any]
        
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
                            
                            // create an alert that notifies the user their email is invalid
                            let alert = UIAlertController(title: "Invalid email field", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                        break
                    default:
                        // create a failure to update email alert
                        let alert = UIAlertController(title: "Failed to Update Email", message: "Could not update email, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
    
    func logout() {
        self.navigationController?.popToRootViewController(animated: true)
        UserDefaults.standard.removeObject(forKey: User.token)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        logout()
    }
    
    func deleteUser() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .delete, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                        self.logout()
                     break
            default:
                // create a failure to delete account alert
                let alert = UIAlertController(title: "Failed to Delete Account", message: "Could not delete your account, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        // create an alert that notifies the user they can't leave email blank
        let alert = UIAlertController(title: "Account Deletion Confirmation", message: "Are you sure you want to delete your account? This action cannot be undone.", preferredStyle: UIAlertController.Style.alert)
        
        // add an OK button to cancel the alert
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: {(action) in self.deleteUser()}))
        
        // present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func savePressed(_ sender: Any) {
        if (email != emailField.text && emailField.text!.count > 0) {
            updateEmail()
        } else if (emailField.text!.count == 0) {
            // create an alert that notifies the user they can't leave email blank
            let alert = UIAlertController(title: "Invalid email field", message: "You must enter a valid email.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
