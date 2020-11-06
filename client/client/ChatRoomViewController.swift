//
//  ChatRoomViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire
import Starscream

class Chat {
    var id: Int = 0
    var message: String = ""
}

class MeChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var message: UILabel!
}

class OtherChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var message: UILabel!
}

class ChatProfile {
    var id: Int = 0
    var profilePhoto: UIImage!
    var name: String = ""
    var anonymous: Bool = false
}

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    
    var roomId: Int = 0
    
    var loading: Bool = true
    
    var totalsChats: Int = 0
    
    var chatsPerPage: Int = 0
    
    var page: Int = 1
    
    var chats: [Chat] = []
    
    var meProfile: ChatProfile = ChatProfile()
    
    var otherProfile: ChatProfile = ChatProfile()
    
    var socket: WebSocket!
    
    var isConnected: Bool = false
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    @IBOutlet weak var chattingText: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var plusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        plusButton.layer.cornerRadius = 18
        
        // reset this view whenever loading it again
        self.loading = true
        self.page = 1
        self.meProfile = ChatProfile()
        self.otherProfile = ChatProfile()
        self.chats = []
        self.isConnected = false
        
        // initiate the web socket connection for this chat room
        let url = URL(string: "\(APIs.chatRoom)/\(roomId)")!
        let request = URLRequest(url: url)
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
        self.socket.connect()

        loadChatHistory(page: page)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.socket.disconnect()
    }
    
    func loadChatHistory(page: Int) {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let chatAPIURL = "\(APIs.chats)/\(roomId)/\(page)"
        self.loading = true
        
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
                                self.meProfile.anonymous = me["anonymous"] as! Bool
                                let mePhotoURL: String = "\(APIs.serverURI)\(me["profile_photo"] as! String)"
                                self.downloadImage(from: URL(string: mePhotoURL)!, to: self.meProfile)
                            }
                            
                            // store the other user's chat profile
                            if initialLoad {
                                let other = json["other"] as! NSDictionary
                                self.otherProfile.id = other["id"] as! Int
                                self.otherProfile.name = other["name"] as! String
                                self.title = self.otherProfile.name
                                self.otherProfile.anonymous = other["anonymous"] as! Bool
                                let otherPhotoURL = "\(APIs.serverURI)\(other["profile_photo"] as! String)"
                                self.downloadImage(from: URL(string: otherPhotoURL)!, to: self.otherProfile)
                            }
                            
                            // store the number of pages and chats
                            self.totalsChats = json["total_chats"] as! Int
                            self.chatsPerPage = json["chats_per_page"] as! Int
                            
                            // store the chats between the users
                            let chats = ResponseSerializer.getChatHistory(json: json["chats"])!
                            self.chats = chats + self.chats
                            self.tableView.reloadData()
                            
                            // scroll to the a view of the table before continuing to load any other pages
                            if initialLoad {
                                self.scrollToBottom(animated: false)
                            } else {
                                let indexPath = IndexPath(row: chats.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                            self.loading = false
                        }
                        break
                    default:
                        // create a failure to load chat history alert
                        let alert = UIAlertController(title: "Failed to Load Chat History", message: "Could not load the chat history, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        self.loading = false
                        break
                }
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(_ ):
                self.isConnected = true
            
                // add a click event to the message bar button item
                self.profileButton.target = self
                self.profileButton.action = #selector(viewProfile(sender:))
            case .disconnected(_ ):
                self.isConnected = false
                break
            case .text(let string):
                let chat = string.toJSON() as? [String: AnyObject]
                let id: Int = chat?["id"] as! Int
                
                if chat?["message"] != nil {
                    let message: String = chat?["message"] as! String
                    
                    // add this message into the list of chats
                    let newChat = Chat()
                    newChat.id = id
                    newChat.message = message
                    chats.append(newChat)
                } else if chat?["request"] != nil {
                    // add a message to this user that the other user wishes to not be anonymous
                    let message: String = "Anonymous would like to reveal both of your profiles. Type ACCEPT or something else to deny."
                    
                    // add this message into the list of chats
                    let newChat = Chat()
                    newChat.id = id
                    newChat.message = message
                    chats.append(newChat)
                }
                
                self.tableView.reloadData()
                
                // scroll to the bottom if this user sent the message
                if id == meProfile.id {
                    scrollToBottom(animated: true)
                }
                break
            case .cancelled:
                self.isConnected = false
                break
            case .error(_ ):
                self.isConnected = false
                break
            default:
                break
        }
    }
    
    @objc func viewProfile(sender : UIBarButtonItem) {
        if otherProfile.anonymous {
            // send a message to the socket that the user wishes to no longer be anonymous
            let token: String = UserDefaults.standard.string(forKey: User.token)!
            let message = "{ \"token\": \"\(token)\", \"request\": \"\(true)\" }"
            socket?.write(string: message)
        }
    }
    
    func scrollToBottom(animated: Bool) {
        let row = self.chats.count - 1
        if row > 0 {
            let indexPath = IndexPath(row: row, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
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
            cell.message.adjustUILabelHeight()
            
            return cell
        }
        
        // create a chat cell for the other user's chat profile
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "OtherChatCell", for: indexPath as IndexPath) as! OtherChatCell
        
        cell.profilePhoto.image = otherProfile.profilePhoto
        cell.message.text = chat.message
        cell.message.adjustUILabelHeight()
        
        return cell
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?[0]
        let lastPage: Float = Float(totalsChats) / Float(chatsPerPage)
        
        if firstVisibleIndexPath!.row == 0 && Float(page) < lastPage && !self.loading {
            // reached the top of the table view and there exists more chat history, so load the next page
            page += 1
            loadChatHistory(page: page)
        }
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        if chattingText.text == nil || chattingText.text == "" || !self.isConnected {
            return
        }
        
        // send a message to the socket connection
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let message = "{ \"token\": \"\(token)\", \"message\": \"\(chattingText.text!)\" }"
        socket?.write(string: message)
        
        chattingText.text = ""
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
