//
//  registerViewController.swift
//  client
//
//  Created by Jinho Yoon on 10/12/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire
import AuthenticationServices
import GoogleSignIn

class RegisterViewController: UIViewController {
    
    let identitySegueIdentifier: String = "IdentitySegue"

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var googleButton: UIButton!
    
    var googleUserId: String = ""
    
    var oAuthEmail: String = ""
    
    var oAuthPassword: String = ""
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailText.layer.borderWidth = 2
        emailText.layer.borderColor = UIColor.black.cgColor
        passwordText.layer.borderWidth = 2
        passwordText.layer.borderColor = UIColor.black.cgColor
        passwordText.textContentType = .oneTimeCode
        googleButton.layer.cornerRadius = 6
        nextButton.layer.cornerRadius = 6
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    func verifyCredentials(email: String, password: String) {
        let parameters = ["email": email, "password": password]
        
        AF.request(URL.init(string: APIs.verifyCredentials)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        // the credentials were fine, so allow the user to begin the onboarding
                        self.performSegue(withIdentifier: self.identitySegueIdentifier, sender: self)
                        break
                    default:
                        if let json = response.value {
                            let errorMessage: String? = ResponseSerializer.getErrorMessage(json: json)
                            
                            // create a failure register alert
                            let alert = UIAlertController(title: "Registration Failed", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                        break
                }
        }
    }
    
    @IBAction func nextPressed(_ sender: RegisterViewController) {
        verifyCredentials(email: emailText.text ?? "", password: passwordText.text ?? "")
    }
    
    @IBAction func googleButtonPressed(_ sender: Any) {
        if (GIDSignIn.sharedInstance()?.currentUser == nil) {
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identitySegueIdentifier {
            if let identityVC = segue.destination as? IdentityViewController {
                if self.oAuthEmail == "" || self.oAuthPassword == "" {
                    // register using the account system
                    identityVC.email = emailText.text!
                    identityVC.password = passwordText.text!
                } else {
                    // register using OAuth
                    identityVC.googleUserId = self.googleUserId
                    identityVC.email = self.oAuthEmail
                    identityVC.password = self.oAuthPassword
                }
            }
        }
    }
}
