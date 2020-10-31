//
//  IndividualChatViewController.swift
//  Matchus
//
//  Created by Jinho Yoon on 11/1/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class IndividualChatViewController: UIViewController {

    @IBOutlet weak var chattingText: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        plusButton.layer.cornerRadius = 18
        plusButton.layer.borderWidth = 1.5
        plusButton.layer.borderColor = UIColor.black.cgColor
        
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
