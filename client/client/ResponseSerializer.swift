//
//  ResponseSerializer.swift
//  Matchus
//
//  Created by pbhusal on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//
import Foundation
class ResponseSerializer {
    
    static func getToken(json: Any?) -> String? {
        let token = json as! [String: AnyObject]
        let authToken: String? = token["token"] as? String
        
        return authToken
    }
    
    static func getSuccessMessage(json: Any?) -> String? {
        let success = json as! [String: AnyObject]
        let successMessage: String? = success["success"] as? String
        
        return successMessage
    }
    
    static func getErrorMessage(json: Any?) -> String? {
        let error = json as! [String: AnyObject]
        let errorArray: [String]? = Array(error)[0].value as? [String]
        let errorMessage: String? = errorArray?[0]
        
        return errorMessage
    }
    
    static func getProfilePicture(json: Any?) -> String? {
        let photo = json as! [String: AnyObject]
        let profilePhotoURL: String? = photo["profilePhoto"] as? String
        
        return profilePhotoURL
    }
    
    static func getProfileName(json: Any?) -> String? {
        let name = json as! [String: AnyObject]
        let profileName: String? = name["name"] as? String
        
        return profileName
    }
    
    static func getMatchRate(json: Any?) -> String? {
        let match = json as! [String: AnyObject]
        let matchRate: Int? = match["match"] as? Int
        
        return String(matchRate!)
    }
    
    static func getFeaturedPhotoURLs(json: Any?) -> [String]? {
        let urls = json as! [String: AnyObject]
        let photoArray: [String]? = urls["photos"] as? [String]
        
        return photoArray
    }
    
    static func getInterestsList(json: Any?) -> [String]? {
        let interests = json as! [String: AnyObject]
        let interestsArray: [String]? = interests["interests"] as? [String]
        
        return interestsArray
    }
    
    static func getChatsList(json: Any?) -> [RecentChat]? {
        let chats = json as! [NSDictionary]
        var chatsArray: [RecentChat] = []
        
        for chat in chats {
            let recentChat: RecentChat = RecentChat()
            recentChat.id = chat["id"] as! Int
            recentChat.name = chat["name"] as! String
            recentChat.message = chat["message"] as! String
            recentChat.profilePhoto = "\(APIs.serverURI)\(chat["profile_photo"] as! String)"
            chatsArray.append(recentChat)
        }

        return chatsArray
    }
    
    static func getChatHistory(json: Any?) -> [Chat]? {
        let chats = json as! [NSDictionary]
        var chatsArray: [Chat] = []
        
        for chat in chats {
            let chatHistory: Chat = Chat()
            chatHistory.id = chat["id"] as! Int
            chatHistory.message = chat["message"] as! String
            chatsArray.append(chatHistory)
        }

        return chatsArray
    }
    
}
