//
//  EditInterestsViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class EditInterestsViewController: UIViewController {
    
    var interestsList: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadInterests()
    }
    
    func loadInterests() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value as! NSDictionary? {
                        self.interestsList = ResponseSerializer.getInterestsList(json: json)
                     }
                     break
            default:
                // create a failure to load interests alert
                let alert = UIAlertController(title: "Failed to Load Interests", message: "Could not load your profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func updateInterests() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "interests": interestsList! ] as [String : Any]
        
        AF.request(APIs.settings, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value as! NSDictionary? {
                            print(json)
                        }
                        break
                    default:
                        // create a failure to update interests alert
                        let alert = UIAlertController(title: "Failed to Update Interests", message: "Could not update interests, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
}
