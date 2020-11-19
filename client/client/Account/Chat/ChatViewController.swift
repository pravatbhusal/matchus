//
//  ChatViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class RecentChat {
    var id: Int = 0
    var name: String = ""
    var message: String = ""
    var profilePhoto: UIImage!
}

class ChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var recentMessage: UILabel!
    @IBOutlet weak var name: UILabel!
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let chatRoomSegueIdentifier: String = "ChatRoomSegueIdentifier"

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var plusButton: UIButton!
    
    var loadingView: UIActivityIndicatorView!
    
    var chats: [RecentChat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // initiate the activity indicator
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.frame = self.view.frame
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.white
        self.view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadChats()
    }
    
    func loadChats() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        
        AF.request(URL.init(string: APIs.chats)!, method: .get, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            self.chats = ResponseSerializer.getChatsList(json: json)!
                            self.tableView.reloadData()
                            self.loadingView.stopAnimating()
                        }
                        break
                    default:
                        // create a failure to load chats alert
                        let alert = UIAlertController(title: "Failed to Load Chats", message: "Could not load the chats, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath as IndexPath) as! ChatCell
        let row = indexPath.row
        
        cell.profilePhoto.image = chats[row].profilePhoto
        cell.recentMessage.text = chats[row].message
        cell.name.text = chats[row].name

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat: RecentChat = chats[indexPath.row]
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        performSegue(withIdentifier: chatRoomSegueIdentifier, sender: chat)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == chatRoomSegueIdentifier {
            if let chatRoomVC = segue.destination as? ChatRoomViewController {
                // pass over the room id of this chat room
                let chat: RecentChat = sender as! RecentChat
                chatRoomVC.roomId = chat.id
            }
        }
    }
    
}
