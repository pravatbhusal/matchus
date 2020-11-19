//
//  interestsViewController.swift
//  client
//
//  Created by Jinho Yoon on 10/12/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

public var interests: [String] = []

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dashboardSegueIdentifier: String = "DashboardSegueIdentifier"
    
    var googleUserId: String = ""
    
    var email: String = ""
    
    var password: String = ""
    
    var profilePhoto: UIImage!
    
    var name: String = ""
    
    var biography: String = ""
    
    var location: String = ""
    
    var longitude: Double = 0
    
    var latitude: Double = 0
    
    let textCellIdentifier: String = "TextCell"
    
    let minInterests: Int = 4
    
    let tableRowSpacing: CGFloat = 20
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interestText: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return interests.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableRowSpacing
    }
    
    // clears out the section background color
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)

        let row = indexPath.section
        cell.textLabel?.text = interests[row]
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.cornerRadius = 6.0
        
        return cell
    }
    
    @IBAction func xButton(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        interests.remove(at: indexPath!.section)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func addButton(_ sender: Any) {
        var alertTitle: String?
        var alertMessage: String?
        
        if(interestText.text == nil || interestText.text == "") {
            alertTitle = "Invalid input"
            alertMessage = "Please enter text into the interest box."
        }
        
        if alertTitle != nil {
            let alert = UIAlertController(title: alertTitle!, message: alertMessage!, preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        interests.append(interestText.text!)
        interestText.text = ""
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func registerUser(email: String, password: String, location: String, interests: [String]) {
        let parameters = ["google_user_id": googleUserId, "email": email, "password": password, "name": name, "biography": biography, "location": location, "longitude": longitude, "latitude": latitude, "interests": interests] as [String : Any]
        
        AF.request(URL.init(string: APIs.signup)!, method: .post, parameters: parameters as Parameters, encoding: JSONEncoding.default).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 201?:
                        if let json = response.value {
                            // store the user's token in the device's memory
                            let token: String? = ResponseSerializer.getToken(json: json)
                            UserDefaults.standard.set(token, forKey: User.token)
                            
                            // call a separate request to store the profile image
                            self.uploadProfilePhoto(photo: self.profilePhoto)
                        }
                        break
                    default:
                        if let json = response.value {
                            let errorMessage: String? = ResponseSerializer.getErrorMessage(json: json)
                            
                            // create a failure register alert
                            let alert = UIAlertController(title: "Registration Failed", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                            
                            // add an OK button to cancel the alert
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            
                            // present the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                        break
                }
        }
    }
    
    func uploadProfilePhoto(photo: UIImage) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        // format the image into an acceptable form data for the server
        let photoData = photo.jpegData(compressionQuality: 0.5)!
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(photoData, withName: "photo", fileName: "\(self.name).jpeg", mimeType: "image/jpeg")
        }, to: APIs.profilePhoto, method: .post, headers: headers).response { response in
            switch response.result {
                case .success(_ ):
                    self.performSegue(withIdentifier: self.dashboardSegueIdentifier, sender: nil)
                    break
                default:
                    break
            }
        };
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if interests.count >= minInterests {
            registerUser(email: email, password: password, location: location, interests: interests)
        } else {
            // create an alert that notifies the user they need more interests
            let alert = UIAlertController(title: "Not enough interests", message: "Please input at least \(minInterests) interests.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}
