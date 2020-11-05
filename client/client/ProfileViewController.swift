//
//  ProfileViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    let chatRoomSegueIdentifier: String = "ChatRoomSegueIdentifier"
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var messageButton: UIBarButtonItem!
    
    @IBOutlet weak var matchLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var interestsTableView: UITableView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var tag: String = ""
    
    var id: Int = 0
    
    var delegate: UIViewController!
    
    var interests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plusButton.layer.cornerRadius = 18
        interestsTableView.delegate = self
        interestsTableView.dataSource = self
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true

        scrollView.delegate = self
        toggleVisible(visible: false)
        
        // add a click event to the message bar button item
        messageButton.target = self
        messageButton.action = #selector(createChat(sender:))
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
    }
    
    func getProfile() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
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
                                let imageView = UIImageView()
                                if imageView.image == nil {
                                    self.downloadImage(from: URL(string: photoUrl)!, to: imageView)
                                }
                                self.scrollView.addSubview(imageView)
                                print("added imageView to scrollView")
                                imageView.frame = CGRect(x: scrollView.frame.midX, y: scrollView.frame.height/2, width: 75, height: 75)
                                
                            }
                            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(featuredPhotoURLs.count), height: scrollView.frame.size.height)
                            
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
    

    @objc func createChat(sender : UIBarButtonItem) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "profile_id": id ] as [String : Any]
        
        AF.request(URL.init(string: APIs.chats)!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?, 201?:
                        if let json = response.value as! NSDictionary? {
                            let roomId = json["id"] as! Int
                            self.performSegue(withIdentifier: self.chatRoomSegueIdentifier, sender: roomId)
                        }
                        break
                    default:
                        // create a failure to load chat room alert
                        let alert = UIAlertController(title: "Failed to Open Chat", message: "Could not open the chat with this person, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x/scrollView.frame.size.width
        pageControl.currentPage = Int(page)
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
        }
        
    }
    
    
    // logic taken from below
    // https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
    // always download images asynchronously...?
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print("downloaded", url)
            DispatchQueue.main.async() { [weak self] in
                imageView.image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == chatRoomSegueIdentifier {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                // pass over the room id of this chat room
                let roomId: Int = sender as! Int
                chatRoomVC.roomId = roomId
                chatRoomVC.name = profileName.text!
            }
        }
    }

}
