//
//  ChatRoomViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class Chat {
    var id: Int = 0
    var message: String = ""
}

class MeChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var message: UITextView!
}

class OtherChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var message: UITextView!
}

class ChatProfile {
    var id: Int = 0
    var profilePhoto: UIImage!
    var name: String = ""
}

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var roomId: Int = 0
    
    var name: String = ""
    
    var totalsChats: Int = 0
    
    var chatsPerPage: Int = 0
    
    var page: Int = 1
    
    var chats: [Chat] = []
    
    var meProfile: ChatProfile = ChatProfile()
    
    var otherProfile: ChatProfile = ChatProfile()
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var chattingText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var plusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        tableView.delegate = self
        tableView.dataSource = self
        plusButton.layer.cornerRadius = 18
        
        // reset this view whenever loading it again
        self.page = 1
        self.meProfile = ChatProfile()
        self.otherProfile = ChatProfile()
        self.chats = []

        loadChatHistory(page: page)
    }
    
    func loadChatHistory(page: Int) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        let chatAPIURL = "\(APIs.chats)/\(roomId)/\(page)"
        
        AF.request(URL.init(string: chatAPIURL)!, method: .get, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value as! NSDictionary? {
                            let initialLoad: Bool = page == 1
                            
                            // store this user's chat profile
                            if initialLoad {
                                let me = json["me"] as! NSDictionary
                                self.meProfile.id = me["id"] as! Int
                                self.meProfile.name = me["name"] as! String
                                let mePhotoURL: String = "\(APIs.serverURI)\(me["profile_photo"] as! String)"
                                self.downloadImage(from: URL(string: mePhotoURL)!, to: self.meProfile)
                            }
                            
                            // store the other user's chat profile
                            if initialLoad {
                                let other = json["other"] as! NSDictionary
                                self.otherProfile.id = other["id"] as! Int
                                self.otherProfile.name = other["name"] as! String
                                let otherPhotoURL = "\(APIs.serverURI)\(other["profile_photo"] as! String)"
                                self.downloadImage(from: URL(string: otherPhotoURL)!, to: self.otherProfile)
                            }
                            
                            // store the number of pages and chats
                            self.totalsChats = json["total_chats"] as! Int
                            self.chatsPerPage = json["chats_per_page"] as! Int
                            
                            // store the chats between the users
                            let chats = ResponseSerializer.getChatHistory(json: json["chats"])!
                            self.chats += chats
                            self.tableView.reloadData()
                            
                            // scroll to the bottom of the table view on the initial load
                            if initialLoad {
                                self.tableView.scrollToBottom(animated: false)
                            }
                        }
                        break
                    default:
                        // create a failure to load chat history alert
                        let alert = UIAlertController(title: "Failed to Load Chat History", message: "Could not load the chat history, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chats.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message: String = chats[indexPath.row].message
        let minCellHeight = 90
        return message.count < minCellHeight ? CGFloat(minCellHeight) : CGFloat(message.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let chat: Chat = chats[row]
        
        if chat.id == meProfile.id {
            // create a chat cell for my own chat profile
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "MeChatCell", for: indexPath as IndexPath) as! MeChatCell
            
            cell.profilePhoto.image = meProfile.profilePhoto
            cell.message.text = chat.message
            cell.message.adjustUITextViewHeight()
            
            return cell
        }
        
        // create a chat cell for the other user's chat profile
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "OtherChatCell", for: indexPath as IndexPath) as! OtherChatCell
        
        cell.profilePhoto.image = otherProfile.profilePhoto
        cell.message.text = chat.message
        cell.message.adjustUITextViewHeight()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?[0]
        let lastPage: Float = Float(totalsChats) / Float(chatsPerPage)
        
        if firstVisibleIndexPath!.row == 0 && Float(page) < lastPage {
            // reached the top of the table view and there exists more chat history, so load the next page
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            page += 1
            loadChatHistory(page: page)
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to chatProfile: ChatProfile) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 48, height: 48))
                chatProfile.profilePhoto = image
                
                if chatProfile === self.otherProfile {
                    // set the profile button's image to the other user's profile photo
                    self.profileButton.image = image?.withRenderingMode(.alwaysOriginal)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
}
