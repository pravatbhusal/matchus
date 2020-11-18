//
//  LoginViewController.swift
//  client
//
//  Created by Taehyoung Kim on 10/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire
import GoogleSignIn

class LoginViewController: UIViewController {
    
    let dashboardSegueIdentifier: String = "DashboardSegueIdentifier"

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var googleSignInButton: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 6
        emailText.layer.borderWidth = 2
        emailText.layer.borderColor = UIColor.black.cgColor
        passwordText.layer.borderWidth = 2
        passwordText.layer.borderColor = UIColor.black.cgColor
        googleSignInButton.layer.cornerRadius = 6
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    
    func loginUser(googleUserId: String, email: String, password: String) {
        let parameters = ["google_user_id": googleUserId, "email": email, "password": password]
        
        AF.request(URL.init(string: APIs.login)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            // store the user's token in the device's memory
                            let token: String? = ResponseSerializer.getToken(json: json)
                            UserDefaults.standard.set(token, forKey: User.token)
                            self.performSegue(withIdentifier: self.dashboardSegueIdentifier, sender: nil)
                        }
                        break
                    default:
                        if let json = response.value {
                            let errorMessage: String? = ResponseSerializer.getErrorMessage(json: json)
                            
                            // create a failure logged-in alert
                            let alert = UIAlertController(title: "Login Failed", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                        break
                }
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        loginUser(googleUserId: "", email: emailText.text ?? "", password: passwordText.text ?? "")
    }
    
    @IBAction func googleSignIn(_ sender: Any) {
        if (GIDSignIn.sharedInstance()?.currentUser == nil) {
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
}
