//
//  locationViewController.swift
//  client
//
//  Created by Jinho Yoon on 10/12/20.
//  Copyright © 2020 MatchUs. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces

class LocationViewController: UIViewController, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    
    var email: String = ""
    
    var password: String = ""
    
    let interestsSegueIdentifier: String = "InterestsSegue"
    
    @IBOutlet weak var locationText: UITextField!
    
    var manager: CLLocationManager?
    
    var placesClient: GMSPlacesClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestWhenInUseAuthorization()
        
        getCurrentLocation()
    }
    
    func getCurrentLocation() {
        placesClient = GMSPlacesClient()
        
        placesClient?.currentPlace(callback: {
            (placeLikelihoodList, error) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            self.placesClient?.lookUpPlaceID(placeLikelihoodList?.likelihoods[0].place.placeID ?? "", callback: {
                placeResult, error in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    return
                }

                self.setLocationText(place: placeResult!)
            })
        })
    }
    
    func setLocationText(place: GMSPlace) {
        print(place)
        let placeComponents = place.addressComponents?.filter{$0.types.contains("locality") || $0.types.contains("administrative_area_level_1")}
        self.locationText.text = "\(placeComponents?[0].name ?? ""), \(placeComponents?[1].shortName ?? "")"
    }
    
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields

        // specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        filter.country = "us"
        autocompleteController.autocompleteFilter = filter

        // display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }

    @IBAction func nextPressed(_ sender: LocationViewController) {
        if locationText.text != nil && locationText.text != "" {
            performSegue(withIdentifier: interestsSegueIdentifier, sender: sender)
        } else {
            let alert = UIAlertController(title: "Enter a location", message: "Please enter a location into the field.", preferredStyle: UIAlertController.Style.alert)
            
            // add an OK button to cancel the alert
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // present the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == interestsSegueIdentifier {
            if let interestsVC = segue.destination as? InterestsViewController {
                // pass over the location view controller's variables
                interestsVC.email = email
                interestsVC.password = password
                interestsVC.location = locationText.text!
            }
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        setLocationText(place: place)
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
      dismiss(animated: true, completion: nil)
    }
}
