//
//  ChatViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

//class Chat {
//
//    var id: Int!
//    var imageURL: String!
//    var messages: [Message]
//    var name: String!
//
//    init(id: Int, imageURL: String, name: String) {
//        self.id = id
//        self.imageURL = imageURL
//        self.messages = []
//        self.name = name
//    }
//
//    func addMessage(msg: Message) {
//        self.messages.append(msg)
//    }
//
//}
//
//class Message {
//
//    var id: Int
//    var message: String
//
//    init(id: Int, msg: String) {
//        self.id = id
//        self.message = msg
//    }
//
//}

class ChatProfile {
    var profileId: Int = 0
    var name: String = ""
    var message: String = ""
    var profilePhoto: String = ""
}

class ChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var recentMessage: UILabel!
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var chats: [ChatProfile] = []
    var tag: String = ""
    
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
                        // create a failure to load alert
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
        
        downloadImage(from: URL(string: self.chats[row].profilePhoto)!, to: cell.imageView!)
        cell.recentMessage.text = chats[row].message
        
        return cell
        
    }
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, to imageView: UIImageView) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
}
