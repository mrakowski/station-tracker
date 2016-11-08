//
//  STUtilities.swift
//  StationTracker
//
//  Created by Michael Rakowski on 11/7/16.
//  Copyright © 2016 Michael Rakowski. All rights reserved.
//

import UIKit

class STUtilities: NSObject {

    // MARK: Validation
    
    class func zipIsValid(zip: String) -> Bool {
    
        var isValid = true
        
        // Check character count
        if zip.characters.count != 5 {
            isValid = false
        }

        // Check that the zip contains only numbers
        let nonNumbers = NSCharacterSet.decimalDigits.inverted
        if zip.rangeOfCharacter(from: nonNumbers) != nil {
            isValid = false
        }

        return isValid
    }
    
    // MARK: Storage
    
    class func savedLocations() -> [[String : String]] {
    
        var locations: [[String : String]]
        let sKey = "savedLocationsKey"
        
        let tmpLocations = UserDefaults.standard.object(forKey: sKey)
        if let storedLocation = tmpLocations as? Array<[String : String]> {
            locations = storedLocation
        }
        else {
            locations = [[String : String]]()
            UserDefaults.standard.set(locations, forKey: sKey)
            UserDefaults.standard.synchronize()
        }
        
        return locations
    }
    
    class func saveLocation(location: [String: String]) {
    
        let sKey = "savedLocationsKey"
        
        var locations = self.savedLocations()
        //locations.append(location)
        locations.insert(location, at: 0)
        
        UserDefaults.standard.set(locations, forKey: sKey)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Network Requests
    
    class func nextFlyover(lat: String, lng: String, completion: @escaping (String?) -> Void) {
        
        // http://api.open-notify.org/iss-pass.json?lat=LAT&lon=LON
        let urlString = "http://api.open-notify.org/iss-pass.json?lat=\(lat)&lon=\(lng)"
        let url : URL! = URL(string: urlString)
        print(url)
        
        let request = URLRequest(url: url)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil )
        session.dataTask(with: request) {(data, response, error) -> Void in
            
            if let data = data {
                
                var foundTime = false
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                    if let jsonResult = json as? Dictionary<String, AnyObject> {
                        if let times = jsonResult["response"] as? Array<AnyObject> {
                        
                            //print(times)
                            let firstTime = times.first as? Dictionary<String, AnyObject>
                            //print("firstTime:", firstTime)
                            
                            // UTC risetime
                            let riseTime = firstTime?["risetime"] as? Int
                            if riseTime != nil {
                                //print(type(of:riseTime), riseTime)
                                foundTime = true
                                completion(String(riseTime!))
                            }
                        }
                    }
                }
                    
                if foundTime == false {
                    completion(nil)
                }
            
            }
            else {
                completion(nil)
            }
            }.resume()
        
    
    }
    
}
