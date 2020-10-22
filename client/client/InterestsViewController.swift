//
//  interestsViewController.swift
//  client
//
//  Created by Jinho Yoon on 10/12/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit


public var interests:[String] = []

class InterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "TextCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interestText: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)

        let row = indexPath.row
        cell.textLabel?.text = interests[row]
        
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.cornerRadius = 6.0
        
        return cell
    }
    
    @IBAction func xButton(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at:buttonPosition)
        interests.remove(at: indexPath!.row)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func addButton(_ sender: Any) {
        if interests.count < 4 {
            interests.append(interestText.text!)
            interestText.text = ""
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
