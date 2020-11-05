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
    var profilePhoto: String = ""
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
    
    var chats: [RecentChat] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.layer.cornerRadius = 18
        tableView.delegate = self
        tableView.dataSource = self
        loadChats()
    }
    
    func loadChats() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(URL.init(string: APIs.chats)!, method: .get, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if let json = response.value {
                            self.chats = ResponseSerializer.getChatsList(json: json)!
                            self.tableView.reloadData()
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
        
        // to prevent continously downloading the image, only set the image if it hasn't been yet set
        if cell.imageView?.image == nil {
            downloadImage(from: URL(string: self.chats[row].profilePhoto)!, to: cell.imageView!)
        }
        
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
                let chat: RecentChat = (sender as! RecentChat)
                chatRoomVC.roomId = chat.id
                chatRoomVC.name = chat.name
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)?.resizeImage(targetSize: CGSize(width: 75, height: 75))
                self.tableView.reloadData()
            }
        }
    }
}
