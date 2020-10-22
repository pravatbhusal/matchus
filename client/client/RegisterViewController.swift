//
//  registerViewController.swift
//  client
//
//  Created by Jinho Yoon on 10/12/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import AuthenticationServices

class RegisterViewController: UIViewController {

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
    
}

extension RegisterViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let user = User(credentials: appleIDCredential)
            print("id: ", user.id)
            print("name: ", user.firstName)
            print("email: ", user.email)
            
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
        print("Login error", error)
    }
}

extension RegisterViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
