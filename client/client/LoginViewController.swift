//
//  LoginViewController.swift
//  client
//
//  Created by Taehyoung Kim on 10/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // code to enable tapping on the background to remove software keyboard
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
        NSLayoutConstraint.activate([
                                        authorizationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100), authorizationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),authorizationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)])
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
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let user = User(credentials: appleIDCredential)
            print("id: ", user.id)
            print("name: ", user.firstName)
            print("email: ", user.email)
//            performSegue(withIdentifier: "testsegue", sender: user)
            

// auto-login with icloud
//        case let passwordCredential as ASPasswordCredential:
//        
//            // Sign in using an existing iCloud Keychain credential.
//            let username = passwordCredential.user
//            let password = passwordCredential.password
//            
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Login error", error)
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

