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
}

class DashboardCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileTag: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
}

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var profiles:[DashboardProfile] = []
    var pageNum:Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        plusButton.layer.cornerRadius = 18
        loadProfiles()
    }
    
    func loadProfiles() {
        let headers: HTTPHeaders = ["Authorization": "Token \(UserDefaults.standard.string(forKey: User.token) ?? "")"]
        
        let url = APIs.serverURI + "/dashboard/" + String(pageNum)
        
        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value {
                        print(json)
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
        self.profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath as IndexPath) as! DashboardCell
        let row = indexPath.row
        downloadImage(from: URL(string: self.profiles[row].profilePhoto)!, to: cell.profilePhoto)
        downloadImage(from: URL(string: self.profiles[row].photo)!, to: cell.photo)
        cell.profileName.text = profiles[row].name
        cell.profileTag.text = "@\(profiles[row].name.lowercased())"
        print(self.profiles[row].photo)
        return cell
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75))
                self.tableView.reloadData()
            }
        }
    }
}
