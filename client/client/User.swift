//
//  User.swift
//  client
//
//  Created by Taehyoung Kim on 10/14/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import Foundation
import AuthenticationServices

class User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    init(credentials: ASAuthorizationAppleIDCredential) {
        self.id = credentials.user
        self.firstName = credentials.fullName?.givenName ?? ""
        self.lastName = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
    }
}
