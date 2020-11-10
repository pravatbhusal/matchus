//
//  PersonalInfoViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class PersonalInfoViewController: UIViewController {
    
    var profilePhoto: String!
    var profileName: String!
    var profileBio: String!
    var profileLocation: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadInfo()
    }
    
    func loadInfo() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        let url = "\(APIs.serverURI)/profile/settings"
        
        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value as! NSDictionary? {
                        self.profilePhoto = ResponseSerializer.getProfilePicture(json: json)
                        self.profileName = ResponseSerializer.getProfileName(json: json)
                        self.profileBio = ResponseSerializer.getProfileBio(json: json)
                        self.profileLocation = ResponseSerializer.getProfileLocation(json: json)
                     }
                     break
            default:
                // create a failure to load chat history alert
                let alert = UIAlertController(title: "Failed to Load Profile Info", message: "Could not load your profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
