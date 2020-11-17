//
//  PersonalInfoViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire
import GooglePlaces

class PersonalInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var myNameLabel: UITextField!
    @IBOutlet weak var myLocationLabel: UITextField!
    @IBOutlet weak var myBioLabel: UITextView!
    @IBOutlet weak var myProfilePhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var profilePhoto: String!
    var profileName: String!
    var profileBio: String!
    var profileLocation: String!
    var latitude: Double = 0
    var longitude: Double = 0
    
    var originalPhoto: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        myNameLabel.layer.borderWidth = 2
        myLocationLabel.layer.borderWidth = 2
        myBioLabel.layer.borderColor = UIColor.black.cgColor
        myBioLabel.layer.borderWidth = 2
        saveButton.layer.borderWidth = 2
        loadInfo()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
                let image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75))
                imageButton.setBackgroundImage(image, for: .normal)
                self.originalPhoto = image
            }
        }
    }
    
    // Profile photo selector
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
    
    // Location selector
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields

        // specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        filter.country = "us"
        autocompleteController.autocompleteFilter = filter

        // display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func setLocationText(place: GMSPlace) {
        let placeComponents = place.addressComponents?.filter{$0.types.contains("locality") || $0.types.contains("administrative_area_level_1")}
        self.longitude = place.coordinate.longitude
        self.latitude = place.coordinate.latitude
        self.myLocationLabel.text = "\(placeComponents?[0].name ?? ""), \(placeComponents?[1].shortName ?? "")"
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        setLocationText(place: place)
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
      dismiss(animated: true, completion: nil)
    }
    
    func updateInfo(parameters: [String: Any], photoModified: Bool) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if (response.value as! NSDictionary?) != nil {
                            if (photoModified) {
                                self.uploadProfilePhoto(photo: self.myProfilePhotoButton.currentBackgroundImage!)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
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
    
    func uploadProfilePhoto(photo: UIImage) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        // format the image into an acceptable form data for the server
        let photoData = photo.jpegData(compressionQuality: 0.5)!
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(photoData, withName: "photo", fileName: "\(String(describing: self.profileName)).jpeg", mimeType: "image/jpeg")
        }, to: APIs.profilePhoto, method: .post, headers: headers).response { response in
            switch response.result {
                case .success(_ ):
                    self.navigationController?.popViewController(animated: true)
                    break
                default:
                    break
            }
        };
    }
    
    @IBAction func savePressed(_ sender: Any) {
        var photoModified = false
        var parameters: [String: Any] = [:]
        if (profileName != myNameLabel.text) {
            parameters["name"] = myNameLabel.text
        }
        if (profileLocation != myLocationLabel.text) {
            parameters["location"] = myLocationLabel.text
            parameters["latitude"] = latitude
            parameters["longitude"] = longitude
        }
        if (profileBio != myBioLabel.text) {
            parameters["biography"] = myBioLabel.text
        }
        if (originalPhoto != myProfilePhotoButton.currentBackgroundImage) {
            photoModified = true
        }
        updateInfo(parameters: parameters, photoModified: photoModified)
    }
    
}
