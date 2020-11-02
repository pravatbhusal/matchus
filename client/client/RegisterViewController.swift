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

class RegisterViewController: UIViewController {
    
    let locationSegueIdentifier: String = "LocationSegue"

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.layer.cornerRadius = 6
        emailText.layer.borderWidth = 2
        emailText.layer.borderColor = UIColor.black.cgColor
        passwordText.layer.borderWidth = 2
        passwordText.layer.borderColor = UIColor.black.cgColor
        setupProviderLoginView()
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        view.addSubview(authorizationButton)
        NSLayoutConstraint.activate([authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100), authorizationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),authorizationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)])
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    /**
     Return if an email string is a valid email format.
     */
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func verifyCredentials(email: String, password: String) {
        let verifyCredentialsURL: String = "\(Constants.serverURI)/verify-credentials/"
        let parameters = ["email": email, "password": password]
        
        AF.request(URL.init(string: verifyCredentialsURL)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == locationSegueIdentifier {
            if let locationVC = segue.destination as? LocationViewController {
                // pass over the register view controller's variables
                locationVC.email = emailText.text!
                locationVC.password = passwordText.text!
            }
        }
    }
}

extension RegisterViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let email: String = appleIDCredential.email ?? ""
                let password: String = appleIDCredential.user
                print(email, password)

                /*
                    performSegue(withIdentifier: "testsegue", sender: user)

                    // auto-login with icloud
                    case let passwordCredential as ASPasswordCredential:

                    // Sign in using an existing iCloud Keychain credential.
                    let username = passwordCredential.user
                    let password = passwordCredential.password
                */

            default:
                break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Registration Error", error)
    }
}

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
