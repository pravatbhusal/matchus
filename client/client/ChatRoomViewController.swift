//
//  ChatRoomViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    var id: Int = 0
    
    var page: Int = 1

    @IBOutlet weak var chattingText: UITextField!
    
    @IBOutlet weak var plusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plusButton.layer.cornerRadius = 18
        plusButton.layer.borderWidth = 1.5
        plusButton.layer.borderColor = UIColor.black.cgColor
        loadChatRoomPage(page: page)
    }
    
    func loadChatRoomPage(page: Int) {
        
    }
}
