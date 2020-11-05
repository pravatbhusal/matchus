//
//  ProfileViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var interestsTableView: UITableView!
    
    var tag: String!
    var id: Int!
    var delegate: UIViewController!
    var interests: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plusButton.layer.cornerRadius = 18
        interestsTableView.delegate = self
        interestsTableView.dataSource = self
        
        getProfile()
    }
    
    func getProfile() {
        let url = URL.init(string: APIs.profile + tag)!
    
        AF.request(url, method: .get, parameters: nil).responseJSON { [self]
            response in
                   switch response.result {
                       case .success:
                        if let json = response.value {
                            // add download profilephoto from url and set the imageview image
                            let profilePhotoURL: String = ResponseSerializer.getProfilePicture(json: json)!
                            self.downloadImage(from: URL(string: profilePhotoURL)!, to: self.profilePhoto)
                            // set profile name
                            let profileName: String = ResponseSerializer.getProfileName(json: json)!
                            self.profileName.text = profileName
                            
                            let matchRate: String = ResponseSerializer.getMatchRate(json: json)!
                            self.matchLabel.text = "Match Rate: \(matchRate)%"
                            // get all photo urls, then download them and add to the scrollview
                            let featuredPhotoURLs: [String] = ResponseSerializer.getFeaturedPhotoURLs(json: json)!
                            
                            for photoUrl in featuredPhotoURLs {
                                self.stackView.addArrangedSubview(self.image(filename: photoUrl))
                            }
                            // add interests to the array (data source for the table) then reload to reflect changes
                            let interestsData: [String] = ResponseSerializer.getInterestsList(json: json)!
                            self.interests = interestsData
                            self.interestsTableView.reloadData()
                            
                        }

                           
                       case .failure(let error):
                           print(error)
                       }
           }
           
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterestCell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = interests[row]
        return cell
    }
    
    // logic taken from below
    // https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    // always download images asynchronously...?
    
    func image(filename: String) -> UIImageView {
        let imgView = UIImageView()
        downloadImage(from: URL(string: filename)!, to: imgView)
        
        let width = view.frame.width
        var height = view.frame.width
            
        let imgWidth = imgView.image!.size.width
        let imgHeight = imgView.image!.size.height
        height = height * (imgHeight / imgWidth)
            
        imgView.widthAnchor.constraint(equalToConstant: width).isActive = true
        imgView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        return imgView
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)
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
