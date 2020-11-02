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

class LoginViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
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
        setupProviderLoginView()
    }
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        view.addSubview(authorizationButton)
        NSLayoutConstraint.activate([authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100), authorizationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),authorizationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
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
    
    func loginUser(email: String, password: String) {
        let loginURL: String = "\(Constants.serverURI)/login/"
        let parameters = ["email": email, "password": password]
        
        AF.request(URL.init(string: loginURL)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            let successMessage: String? = ResponseSerializer.getSuccessMessage(json: json)
                            
                            // create a successfully logged-in alert
                            let alert = UIAlertController(title: "Logged-in!", message: successMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
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
        loginUser(email: emailText.text ?? "", password: passwordText.text ?? "")
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                let email: String = appleIDCredential.email ?? ""
                let password: String = appleIDCredential.user
                loginUser(email: email, password: password)
            default:
                break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Login Error", error)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

