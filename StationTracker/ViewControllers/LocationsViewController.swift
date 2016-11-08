//
//  ViewController.swift
//  StationTracker
//
//  Created by Michael Rakowski on 11/7/16.
//  Copyright © 2016 Michael Rakowski. All rights reserved.
//

import UIKit

class LocationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var flyoverTimes = [String : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Fetch flyover times for each location
        var count = 0
        let locations = STUtilities.savedLocations()
        for location in locations {
        
            let lat = location["lat"]!
            let lng = location["lng"]!
            
            STUtilities.nextFlyover(lat: lat, lng: lng) {(tmpString: String?) in
                
                if tmpString != nil {
                    
                    let timeInterval = Double(tmpString!)
                    let pDate = NSDate.init(timeIntervalSince1970: timeInterval!)
                    
                    let df = DateFormatter()
                    df.dateFormat = "Y-MM-dd H:ma"
                    let dateString = df.string(from: pDate as Date)
                    
                    let cKey = "\(lat)-\(lng)"
                    self.flyoverTimes[cKey] = dateString
                }
                count = count + 1
                
                if count == locations.count {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK:
    
    @IBAction func showEnterLocation() {
    
        self.performSegue(withIdentifier: "locationsToEnterLocation", sender: self)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let locationCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        let locations = STUtilities.savedLocations()
        let location = locations[indexPath.row]
        let lat = location["lat"]!
        let lng = location["lng"]!
        
        locationCell.textLabel?.text = location["zipcode"]! + " (" + lat + ", " + lng + ")"
        
        let cKey = "\(lat)-\(lng)"
        let displayTime = flyoverTimes[cKey]
        if displayTime != nil {
            locationCell.detailTextLabel?.text = "Next flyover: " + displayTime!
        }
        else {
            locationCell.detailTextLabel?.text = ""
        }
        
        return locationCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let locations = STUtilities.savedLocations()
        let rows = locations.count

        return rows
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let height = CGFloat(100.0)
        
        return height
    }
    
}

