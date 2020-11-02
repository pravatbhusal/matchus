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
    var profileId: Int!
    var name: String!
    var recentMessage: String!
    var profileImageURL: String!
}

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var recentMessage: UILabel!
    
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusButton: UIButton!
    
    var chats: [ChatProfile]!
    var tag:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plusButton.layer.cornerRadius = 18
        tableView.delegate = self
        tableView.dataSource = self
        loadChats()
    }
    
    func loadChats() {
        let url = URL.init(string: APIs.chats + tag)!
        
        AF.request(url, method: .get, parameters: nil).responseJSON { [self]
            response in
                   switch response.result {
                       case .success:
                        if let json = response.value {
                            // populate chats array here
                            
                            let chatProfiles: [ChatProfile] = ResponseSerializer.getChatProfiles(json: json)!
                            
                        }
                           
                       case .failure(let error):
                           print(error)
                       }
           }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath as IndexPath) as! ChatCell
        let row = indexPath.row
        
        downloadImage(from: URL(string: self.chats[row].profileImageURL)!, to: cell.imageView!)
        cell.recentMessage.text = chats[row].recentMessage
        
        return cell
        
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
