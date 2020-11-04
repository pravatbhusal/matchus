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
    
    let locationSegueIdentifier: String = "LocationSegue"

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var googleButton: UIButton!
    
    
    var email: String = ""
    var password: String = ""
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
        googleButton.layer.cornerRadius = 6
        emailText.layer.borderWidth = 2
        emailText.layer.borderColor = UIColor.black.cgColor
        passwordText.layer.borderWidth = 2
        passwordText.layer.borderColor = UIColor.black.cgColor
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    func verifyCredentials(email: String, password: String) {
        let parameters = ["email": email, "password": password]
        
        AF.request(URL.init(string: APIs.verifyCredentials)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        // the credentials were fine, so allow the user to begin the onboarding
                        self.performSegue(withIdentifier: self.locationSegueIdentifier, sender: self)
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
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            let email: String = user.profile.email
            let password: String = user.userID
            self.email = email
            self.password = password
//            print("Email: ", email)
//            print("Password: ", password)
            verifyCredentials(email: email, password: password)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == locationSegueIdentifier {
            if let locationVC = segue.destination as? LocationViewController {
                // pass over the register view controller's variables
                if (self.email == "" || self.password == "") {
                    locationVC.email = emailText.text!
                    locationVC.password = passwordText.text!
                } else {
                    locationVC.email = self.email
                    locationVC.password = self.password
                }
            }
        }
    }
}
