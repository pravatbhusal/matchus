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
        
        getLocations()
    }
    
    func getLocations() {
        placesClient = GMSPlacesClient()
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error:Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let placeComponents = placeLikelihoodList[0].place.addressComponents?.filter{$0.types.contains("locality") || $0.types.contains("administrative_area_level_1")}
                self.locationText.text = "\(placeComponents?[0].name ?? ""), \(placeComponents?[1].shortName ?? "")"
                self.locationText.text = placeLikelihoodList[0].place.formattedAddress
            }
        })
    }
    
    @IBAction func autocompleteClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) | UInt(GMSPlaceField.placeID.rawValue))
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
        print(place)
        let placeComponents = place.addressComponents?.filter{$0.types.contains("locality") || $0.types.contains("administrative_area_level_1")}
        locationText.text = "\(placeComponents?[0].name ?? ""), \(placeComponents?[1].shortName ?? "")"
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
