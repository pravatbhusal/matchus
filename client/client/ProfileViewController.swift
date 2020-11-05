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
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var interestsTableView: UITableView!
    
    var tag: String!
    var id: Int!
    var delegate: UIViewController!
    var interests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plusButton.layer.cornerRadius = 18
        interestsTableView.delegate = self
        interestsTableView.dataSource = self
        toggleVisible(visible: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getProfile()
    }
    
    func toggleVisible(visible: Bool) {
        loading.isHidden = visible
        profilePhoto.isHidden = !visible
        profileName.isHidden = !visible
        interestsTableView.isHidden = !visible
        matchLabel.isHidden = !visible
        scrollView.isHidden = !visible
        stackView.isHidden = !visible
    }
    
    func getProfile() {
        let headers: HTTPHeaders = ["Authorization": "Token \(UserDefaults.standard.string(forKey: User.token) ?? "")"]

        let url = URL.init(string: "\(APIs.profile)/\(String(id))")!
    
        AF.request(url, method: .get, parameters: nil, headers: headers).responseJSON { [self]
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
                            self.toggleVisible(visible: true)
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
    
    // right swipe
    func tableView(_ tableView: UITableView,
                    leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let like = UIContextualAction(style: .normal, title:  "👍🏼", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("Liked interest")
            self.likeInterest(interest: self.interests[indexPath.row])
            success(true)
        })
//        like.image = #imageLiteral(resourceName: "like")
//        like.image?.withTintColor(.white)
        
        like.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
     
        return UISwipeActionsConfiguration(actions: [like])
     
     }
     
    // left swipe
     func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
     {
         let dislike = UIContextualAction(style: .destructive, title:  "👎🏼", handler: { (ac:UIContextualAction, view:UIView, nil) in
             print("Disliked interest")
            self.interests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
         })
//         dislike.image = #imageLiteral(resourceName: "dislike")
//         dislike.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
     
         return UISwipeActionsConfiguration(actions: [dislike])
     }
    
    func likeInterest(interest: String) {
        print(interest)
        let parameters: [String: Any] = ["interest" : interest]
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(URL.init(string: APIs.interests)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            print(response.response?.statusCode)
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            print(json)

                        }
                        break
                    default:
                        if let json = response.value {
                            print(json)

                        }
                        break
                }
        }
        
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
