//
//  EnterLocationViewController.swift
//  StationTracker
//
//  Created by Michael Rakowski on 11/7/16.
//  Copyright © 2016 Michael Rakowski. All rights reserved.
//

import UIKit
import CoreLocation

class EnterLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textField.becomeFirstResponder()
    }

    // MARK: Actions
    
    @IBAction func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAction() {
        
        // Convert zip to coords and save it
        
        let geocoder = CLGeocoder.init()
        let zip = self.textField.text!
        geocoder.geocodeAddressString(zip, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) -> Void in
          
            if placemarks != nil && placemarks!.count > 0 {
                
                let firstPlacemark = placemarks!.first!
                //print(firstPlacemark)
                
                if let location = firstPlacemark.location {
                
                    let lat = location.coordinate.latitude
                    let lng = location.coordinate.longitude
                    
                    // Save zipcode, and lat long,
                    let locationD = ["zipcode": zip, "lat": String(lat), "lng": String(lng)]
                    
                    // Save location dictionary
                    STUtilities.saveLocation(location: locationD)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else {
                // Show an alert that the location could not be found
                let displayTitle = "Location Not Found"
                let displayMessage = "Please try a different location"
                let alertController = UIAlertController.init(title: displayTitle,
                                                             message: displayMessage,
                                                             preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true) { () -> Void in
                }
            }
        })
    }
    
    // MARK: 
    
    func validateZip(zipcode: String) {
        // Check if zip is valid. If yes, enable Add button.
        let validZip = STUtilities.zipIsValid(zip: zipcode)
        self.addBarButtonItem.isEnabled = validZip
    }
    
    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let tmpText: NSString = (textField.text ?? "") as NSString
        let resultString = tmpText.replacingCharacters(in: range, with: string)
        validateZip(zipcode: resultString)
        
        return true
    }
    
}
