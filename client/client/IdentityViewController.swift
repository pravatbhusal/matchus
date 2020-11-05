//
//  IdentityViewController.swift
//  Matchus
//
//  Created by pbhusal on 11/5/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit

class IdentityViewController: UIViewController {
    
    let locationSegueIdentifier: String = "LocationSegue"
    
    var email: String = ""
    
    var password: String = ""

    @IBOutlet weak var firstNameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if firstNameText.text == nil || firstNameText.text == "" {
            // create a failure alert because there were missing fields
            let alert = UIAlertController(title: "Missing Fields", message: "Please leave no fields blank.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: self.locationSegueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == locationSegueIdentifier {
            if let locationVC = segue.destination as? LocationViewController {
                // pass over the identity view controller's variables
                locationVC.email = email
                locationVC.password = password
                locationVC.name = firstNameText.text!
            }
        }
    }
    
}
