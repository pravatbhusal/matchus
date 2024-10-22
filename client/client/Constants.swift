//
//  Constants.swift
//  Matchus
//
//  Created by pbhusal on 10/22/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

struct APIKeys {
    
    static let gmsPlacesAPIKey: String = "AIzaSyDp2K1mkC9_73l2kAq3okvRIc_WKxIMLtk"
    
    static let googleSignAPIKey: String = "593493559154-4564ahmp4fl20r8lrju29nk1ng5d5hkt.apps.googleusercontent.com"
}

struct APIs {
    
    static let serverURI: String = "http://127.0.0.1:8000"
    
    static let socketURI: String = "ws://127.0.0.1:8000"
    
    static let login: String = "\(serverURI)/login"
    
    static let signup: String = "\(serverURI)/signup"
    
    static let verifyAuthentication: String = "\(serverURI)/verify-authentication"
    
    static let verifyCredentials: String = "\(serverURI)/verify-credentials"
    
    static let dashboard: String = "\(serverURI)/dashboard"
    
    static let profile: String = "\(serverURI)/profile"
    
    static let featuredPhotos: String = "\(serverURI)/profile/photos"
    
    static let profilePhoto: String = "\(serverURI)/profile/profile-photo"
    
    static let settings: String = "\(serverURI)/profile/settings"
    
    static let chats: String = "\(serverURI)/chats"
    
    static let interests: String = "\(serverURI)/profile/interests"

    static let chatRoom: String = "\(socketURI)/ws/chat-room"

    
}

struct User {
    
    static let token: String = "Token"
    
}
