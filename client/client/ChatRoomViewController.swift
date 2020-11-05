//
//  ChatRoomViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class Chat {
    var name: String = ""
    var message: String = ""
}

class MeChatCell: UITableViewCell {
    
}

class OtherChatCell: UITableViewCell {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var message: UITextView!
}

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var roomId: Int = 0
    
    var name: String = ""
    
    var page: Int = 1
    
    var chats: [Chat] = []
    
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
        tableView.estimatedRowHeight = 90.0
        tableView.rowHeight = UITableView.automaticDimension
        loadChatRoomPage(page: page)
    }
    
    func loadChatRoomPage(page: Int) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "OtherChatCell", for: indexPath as IndexPath) as! OtherChatCell
        let row = indexPath.row
        
        cell.message.text = chats[row].message
        cell.message.adjustUITextViewHeight()
        
        return cell
        
    }
}
