//
//  PersonalInfoViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class PersonalInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var myNameLabel: UITextField!
    @IBOutlet weak var myLocationLabel: UITextField!
    @IBOutlet weak var myBioLabel: UITextField!
    @IBOutlet weak var myProfilePhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var profilePhoto: String!
    var profileName: String!
    var profileBio: String!
    var profileLocation: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myNameLabel.layer.borderWidth = 2
        myLocationLabel.layer.borderWidth = 2
        myBioLabel.layer.borderWidth = 2
        saveButton.layer.borderWidth = 2
        loadInfo()
    }
    
    func loadInfo() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value as! NSDictionary? {
                        self.profilePhoto = ResponseSerializer.getProfilePicture(json: json)
                        self.profileName = ResponseSerializer.getProfileName(json: json)
                        self.profileBio = ResponseSerializer.getProfileBio(json: json)
                        self.profileLocation = ResponseSerializer.getProfileLocation(json: json)
                        
                        self.myNameLabel.text = self.profileName
                        self.myLocationLabel.text = self.profileLocation
                        self.myBioLabel.text = self.profileBio
                        self.downloadImage(from: URL(string: profilePhoto)!, to: self.myProfilePhotoButton)
                     }
                     break
            default:
                // create a failure to load profile info alert
                let alert = UIAlertController(title: "Failed to Load Profile Info", message: "Could not load your profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageButton: UIButton) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageButton.setBackgroundImage(UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75)), for: .normal)
            }
        }
    }
    
    @IBAction func profilePhotoPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        myProfilePhotoButton.setBackgroundImage(image, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func updateInfo() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "profile_photo": profilePhoto!, "name": profileName!, "biography": profileBio!, "location": profileLocation! ] as [String : Any]
        
        AF.request(APIs.settings, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value as! NSDictionary? {
                            print(json)
                        }
                        break
                    default:
                        // create a failure to update profile info alert
                        let alert = UIAlertController(title: "Failed to Update Profile Info", message: "Could not update profile info, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
}
