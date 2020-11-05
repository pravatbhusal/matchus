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
    
    static func getChatsList(json: Any?) -> [ChatProfile]? {
        let chats = json as! [NSDictionary]
        let chatsArray: [ChatProfile] = []

        return chatsArray
    }
    
    static func getDashboardList(json: Any?) -> [DashboardProfile]? {
        let dashboard = json as! [NSDictionary]
        var dashboardArray: [DashboardProfile] = []
        
        for profile in dashboard {
            let dashboardProfile: DashboardProfile = DashboardProfile()
            dashboardProfile.id = profile["id"] as? Int
            dashboardProfile.name = profile["name"] as? String
            dashboardProfile.profilePhoto = profile["profile_photo"] as? String
            dashboardProfile.photo = profile["photo"] as? String
            dashboardProfile.profileTag = profile["tag"] as? String
            dashboardArray.append(dashboardProfile)
        }
        
        return dashboardArray
    }
    
//    static func getChatMessages(json: Any?) -> [Chat]? {
//        let chats = json as! [String: AnyObject]
//        let profiles = chats["profiles"] as! [String: AnyObject]
//        let messages = chats["chats"] as! [String: AnyObject]
//
//        // do stuff with profiles and return messages array
//
//    }
    
}
