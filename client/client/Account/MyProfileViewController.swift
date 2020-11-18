//
//  MyProfileViewController.swift
//  Matchus
//
//  Created by promazo on 11/17/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class MyProfileViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var profilePhoto: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var image1: UIButton!
    
    @IBOutlet weak var image2: UIButton!
    
    @IBOutlet weak var image3: UIButton!
    
    @IBOutlet weak var image4: UIButton!
    
    var loadingView: UIActivityIndicatorView!
    
    var modifiedImage: UIButton!
    
    @IBOutlet weak var profileName: UILabel!
    
    let tableRowSpacing: CGFloat = 20
    
    var interests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.layer.cornerRadius = 6
        settingsButton.layer.borderWidth = 2
        tableView.delegate = self
        tableView.dataSource = self
        
        // initiate the activity indicator
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.center = self.view.center
        self.view.addSubview(loadingView)
        toggleVisible(visible: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadProfile()
    }
    
    func toggleVisible(visible: Bool) {
        // loading.isHidden = visible
        if !visible {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
        profilePhoto.isHidden = !visible
        profileName.isHidden = !visible
        bioLabel.isHidden = !visible
        tableView.isHidden = !visible
    }
    
    func loadProfile() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let url = URL.init(string: "\(APIs.settings)")!
    
        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { [self]
            response in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            // add download profilephoto from url and set the imageview image
                            let profilePhotoURL: String = ResponseSerializer.getProfilePicture(json: json)!
                            self.downloadToImageView(from: URL(string: profilePhotoURL)!, to: self.profilePhoto)
                            
                            self.bioLabel.text = ResponseSerializer.getProfileBio(json: json)!
                            
                            // set profile name
                            let profileName: String = ResponseSerializer.getProfileName(json: json)!
                            self.profileName.text = profileName
    
                            
                            // get all photo urls, then download them and add to the scrollview
                            let featuredPhotoURLs: [String] = ResponseSerializer.getFeaturedPhotoURLs(json: json)!
                            let imageViewsToLoad : [UIButton] = [self.image1, self.image2, self.image3, self.image4]
                            
                            var index = 0
                            var total = 4
                            if featuredPhotoURLs.count < 4 {
                                total = featuredPhotoURLs.count
                            }
                            
                            // download each image that this user owns
                            while index < total {
                                self.downloadtoUIbutton(from: URL(string: featuredPhotoURLs[featuredPhotoURLs.count - index - 1])!, to: imageViewsToLoad[index])
                                index += 1
                            }
                            
                            // add interests to the array (data source for the table) then reload to reflect changes
                            let interestsData: [String] = ResponseSerializer.getInterestsList(json: json)!
                            self.interests = interestsData
                            self.tableView.reloadData()
                            toggleVisible(visible: true)
                        }
                    default:
                        // create a failure to load profile alert
                        let alert = UIAlertController(title: "Failed to Load Profile", message: "Could not load this profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
            }
        }
    }
    
    @IBAction func image1Pressed(_ sender: Any) {
        self.modifiedImage = self.image1
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func image2Pressed(_ sender: Any) {
        self.modifiedImage = self.image2
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    @IBAction func image3Pressed(_ sender: Any) {
        self.modifiedImage = self.image3
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    @IBAction func image4Pressed(_ sender: Any) {
        self.modifiedImage = self.image4
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
        
        self.modifiedImage.setBackgroundImage(image, for: .normal)
        
        uploadProfilePhoto(photo: image)
        
    }
    
    func uploadProfilePhoto(photo: UIImage) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)", "Content-type": "multipart/form-data" ]
        
        // format the image into an acceptable form data for the server
        let photoData = photo.jpegData(compressionQuality: 1)!
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(photoData, withName: "photo", fileName: "\(String(describing: self.profileName)).jpeg", mimeType: "image/jpeg")
        }, to: APIs.featuredPhotos, method: .post, headers: headers).response { response in
            switch response.result {
                case .success(_ ):
                    break
                default:
                    break
            }
        };
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath as IndexPath)
        let row = indexPath.section
        cell.textLabel?.text = interests[row]
        cell.contentView.layer.borderWidth = 2.5
        cell.contentView.layer.cornerRadius = 4.0
        return cell
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadToImageView(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75))
            }
        }
    }
    
    func downloadtoUIbutton(from url: URL, to imageView: UIButton) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.setBackgroundImage(UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 370, height: 370)), for: .normal)
            }
        }
    }
}
