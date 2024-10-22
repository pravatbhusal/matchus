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
    var profilePhoto: UIImage!
    var photo: UIImage!
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
    
    var loadingView: UIActivityIndicatorView!
    
    let profileSegueIdentifier = "ProfileSegue"

    var profiles: [DashboardProfile] = []
    
    var totalProfiles: Int = 0
    
    var profilesPerPage: Int = 0
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // initiate the activity indicator
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.frame = self.view.frame
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.white
        self.view.addSubview(loadingView)
        loadingView.startAnimating()
        
        loadProfiles(page: page)
    }
    
    func loadProfiles(page: Int) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let url = "\(APIs.dashboard)/\(String(page))"
        
        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                case 200?:
                    if let json = response.value as! NSDictionary? {
                        self.totalProfiles = json["total_profiles"] as! Int
                        self.profilesPerPage = json["profiles_per_page"] as! Int

                        let profiles: [DashboardProfile] = ResponseSerializer.getDashboardList(json: json["profiles"], tableView: self.tableView)!
                        self.profiles = self.profiles + profiles
                        self.tableView.reloadData()
                    }
                    loadingView.stopAnimating()
                    break
                default:
                    // create a failure to load chat history alert
                    let alert = UIAlertController(title: "Failed to Load Dashboard", message: "Could not load the dashboard, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an OK button to cancel the alert
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // present the alert
                    self.present(alert, animated: true, completion: nil)
                    break
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "DashboardCell", for: indexPath as IndexPath) as! DashboardCell
        let row = indexPath.row
        
        cell.profilePhoto.image = self.profiles[row].profilePhoto
        cell.photo.image = self.profiles[row].photo
        cell.profileName.text = profiles[row].name
        cell.profileTag.text = "@\(profiles[row].name.lowercased())"
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let lastPage: Float = Float(totalProfiles) / Float(profilesPerPage)
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height && Float(page) < lastPage {
            page += 1
            loadProfiles(page: page)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == profileSegueIdentifier {
            if let profileVC = segue.destination as? ProfileViewController {
                profileVC.id = sender as! Int
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedProfile: DashboardProfile = profiles[row]
        
        performSegue(withIdentifier: profileSegueIdentifier, sender: selectedProfile.id)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
