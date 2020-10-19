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

class locationViewController: UIViewController, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    @IBOutlet weak var locationText: UITextField!
    var manager: CLLocationManager?
    var placesClient: GMSPlacesClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))
        autocompleteController.placeFields = fields

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        filter.country = "us"
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        setLocationText(place: place)
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      // TODO: handle the error.
      print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
      dismiss(animated: true, completion: nil)
    }
}
