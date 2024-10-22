//
//  ResponseSerializer.swift
//  Matchus
//
//  Created by pbhusal on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import Foundation
import UIKit

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
        let profilePhotoURL: String? = "\(APIs.serverURI)\(photo["profile_photo"] as? String ?? "")"
        
        return profilePhotoURL
    }
    
    static func getProfileName(json: Any?) -> String? {
        let name = json as! [String: AnyObject]
        let profileName: String? = name["name"] as? String
        
        return profileName
    }
    
    static func getProfileBio(json: Any?) -> String? {
        let bio = json as! [String: AnyObject]
        let profileBio: String? = bio["biography"] as? String
        
        return profileBio
    }
    
    static func getProfileLocation(json: Any?) -> String? {
        let location = json as! [String: AnyObject]
        let profileLocation: String? = location["location"] as? String
        
        return profileLocation
    }
    
    static func getProfileEmail(json: Any?) -> String? {
        let email = json as! [String: AnyObject]
        let profileEmail: String? = email["email"] as? String
        
        return profileEmail
    }
    
    static func isProfileOAuth(json: Any?) -> Bool? {
        let email = json as! [String: AnyObject]
        let isOAuth: Bool? = email["oauth"] as? Bool
        
        return isOAuth
    }
    
    static func getMatchRate(json: Any?) -> String? {
        let match = json as! [String: AnyObject]
        let matchRate: Double? = match["match"] as? Double
        let percent: Int = Int(matchRate! * 100)
        
        return String(percent)
    }
    
    static func getFeaturedPhotoURLs(json: Any?) -> [String]? {
        let urls = json as! [String: AnyObject]
        let photoArray = urls["photos"] as! [NSDictionary]
        
        var photoUrls: [String] = []
        
        for photo in photoArray {
            photoUrls.append("\(APIs.serverURI)\(photo["photo"] as! String)")
        }
        return photoUrls
    }
    
    static func getInterestsList(json: Any?) -> [String]? {
        let interests = json as! [String: AnyObject]
        let interestsArray: [String]? = interests["interests"] as? [String]
        
        return interestsArray
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
    
    static func getChatsList(json: Any?, tableView: UITableView) -> [RecentChat]? {
        let chats = json as! [NSDictionary]
        var chatsArray: [RecentChat] = []
        
        for chat in chats {
            let recentChat: RecentChat = RecentChat()
            recentChat.id = chat["id"] as! Int
            recentChat.name = chat["name"] as! String
            recentChat.message = chat["message"] as! String
            
            // download the profile photo
            let profilePhotoURL: String = "\(APIs.serverURI)\(chat["profile_photo"] as! String)"
            downloadChatImage(from: URL(string: profilePhotoURL)!, to: recentChat, tableView: tableView)
            
            chatsArray.append(recentChat)
        }

        return chatsArray
    }
    
    static func getDashboardList(json: Any?, tableView: UITableView) -> [DashboardProfile]? {
        let dashboard = json as! [NSDictionary]
        var dashboardArray: [DashboardProfile] = []
        
        for profile in dashboard {
            let dashboardProfile: DashboardProfile = DashboardProfile()
            dashboardProfile.id = profile["id"] as? Int
            dashboardProfile.name = profile["name"] as? String
            
            // download the profile photo
            let profilePhotoURL: String = "\(APIs.serverURI)\(profile["profile_photo"] as! String)"
            downloadDashboardImage(from: URL(string: profilePhotoURL)!, to: dashboardProfile, tableView: tableView, isProfilePhoto: true)
            
            // download the featured photo
            let photoURL: String = "\(APIs.serverURI)\(profile["photo"] as! String)"
            downloadDashboardImage(from: URL(string: photoURL)!, to: dashboardProfile, tableView: tableView, isProfilePhoto: false)
            
            dashboardArray.append(dashboardProfile)
        }

        
        return dashboardArray
    }
    
    static func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    static func downloadDashboardImage(from url: URL, to profile: DashboardProfile, tableView: UITableView, isProfilePhoto: Bool) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                if isProfilePhoto {
                    profile.profilePhoto = UIImage(data: data)
                } else {
                    profile.photo = UIImage(data: data)
                }
                tableView.reloadData()
            }
        }
    }
    
    static func downloadChatImage(from url: URL, to chat: RecentChat, tableView: UITableView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                chat.profilePhoto = UIImage(data: data)
                tableView.reloadData()
            }
        }
    }
}
