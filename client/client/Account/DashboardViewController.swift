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
    
    let profileSegueIdentifier = "ProfileSegue"

    var profiles: [DashboardProfile] = []
    
    var totalProfiles: Int = 0
    
    var profilesPerPage: Int = 0
    
    var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false;
        loadProfiles(page: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
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
                        
                        let profiles: [DashboardProfile] = ResponseSerializer.getDashboardList(json: json["profiles"])!
                        self.profiles = self.profiles + profiles
                        self.tableView.reloadData()
                     }
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
        
        // download the profile photo image if it's already not downloaded
        if cell.profilePhoto.image == nil {
            downloadImage(from: URL(string: self.profiles[row].profilePhoto)!, to: cell.profilePhoto)
        }
        // download the photo if it's already not downloaded
        if cell.photo.image == nil {
            downloadImage(from: URL(string: self.profiles[row].photo)!, to: cell.photo)
        }
        
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
