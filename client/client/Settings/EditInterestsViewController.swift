//
//  EditInterestsViewController.swift
//  Matchus
//
//  Created by promazo on 11/10/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import Alamofire

class EditInterestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var interestText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var loadingView: UIActivityIndicatorView!
    
    var interestsList: [String] = []
    
    let minInterests: Int = 4
    
    let textCellIdentifier: String = "EditTextCell"
    
    let tableRowSpacing: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        saveButton.layer.borderWidth = 2
        
        // initiate the activity indicator
        loadingView = UIActivityIndicatorView(style: .large)
        loadingView.frame = self.view.frame
        loadingView.center = self.view.center
        loadingView.backgroundColor = UIColor.white
        self.view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadInterests()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return interestsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableRowSpacing
    }
    
    // clears out the section background color
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)

        let row = indexPath.section
        cell.textLabel?.text = interestsList[row]
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.cornerRadius = 6.0
        
        return cell
    }
    
    @IBAction func xButton(_ sender: Any) {
        let buttonPosition = (sender as AnyObject).convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        
        interestsList.remove(at: indexPath!.section)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        var alertTitle: String?
        var alertMessage: String?
        
        if(interestText.text == nil || interestText.text == "") {
            alertTitle = "Invalid input"
            alertMessage = "Please enter text into the interest box."
        }
        
        if alertTitle != nil {
            let alert = UIAlertController(title: alertTitle!, message: alertMessage!, preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        interestsList.append(interestText.text!)
        interestText.text = ""
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadInterests() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = ["Authorization": "Token \(token)" ]
        
        AF.request(APIs.settings, method: .get, parameters: nil, headers: headers).responseJSON { [self]
         response in
            switch response.response?.statusCode {
                    case 200?:
                     if let json = response.value as! NSDictionary? {
                        self.interestsList = ResponseSerializer.getInterestsList(json: json)!
                        self.tableView.reloadData()
                        self.loadingView.stopAnimating()
                     }
                     break
            default:
                // create a failure to load interests alert
                let alert = UIAlertController(title: "Failed to Load Interests", message: "Could not load your profile, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                
                // add an OK button to cancel the alert
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // present the alert
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
    
    func updateInterests() {
        let token: String = UserDefaults.standard.string(forKey: User.token)!
        let headers: HTTPHeaders = [ "Authorization": "Token \(token)" ]
        let parameters = [ "interests": interestsList ] as [String : Any]
        
        AF.request(APIs.settings, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
                switch response.response?.statusCode {
                    case 200?:
                        if (response.value as! NSDictionary?) != nil {
                            self.navigationController?.popViewController(animated: true)
                        }
                        break
                    default:
                        // create a failure to update interests alert
                        let alert = UIAlertController(title: "Failed to Update Interests", message: "Could not update interests, is your internet down?", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an OK button to cancel the alert
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // present the alert
                        self.present(alert, animated: true, completion: nil)
                        break
                }
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if interestsList.count >= minInterests {
            updateInterests()
        } else {
            // create an alert that notifies the user they need more interests
            let alert = UIAlertController(title: "Not enough interests", message: "Please input at least \(minInterests) interests.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
