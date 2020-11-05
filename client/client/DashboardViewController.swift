//
//  DashboardViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class DashboardProfile {
    var id: Int!
    var name: String!
    var profilePhoto: String!
    var photo: String!
    var profileTag: String!
}

class DashboardCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileTag: UILabel!
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var token: String!
    var profiles:[DashboardProfile]!
    var pageNum:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.layer.cornerRadius = 18
        token = UserDefaults.standard.string(forKey: User.token)
        pageNum = 1
        loadProfiles()
    }
    
    func loadProfiles() {
        let url = APIs.serverURI + "/dashboard/" + String(pageNum)
        
        AF.request(url, method: .get, parameters: nil, headers: ["Authorization": token]).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value {
                        // populate dashboard array here
                        let dashboardProfiles: [DashboardProfile] = ResponseSerializer.getDashboardList(json: json)!
                        self.profiles = dashboardProfiles
                        self.tableView.reloadData()
                     }
                     break;
            default:
                if let json = response.value {
                    let errorMessage: String? = ResponseSerializer.getErrorMessage(json: json)
                    print(errorMessage ?? "")
                }
                break;
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath as IndexPath) as! DashboardCell
        let row = indexPath.row
        
        return cell
    }
}
