//
//  ViewController.swift
//  locationServicesTestApp
//
//  Created by Carlos Huang on 2020-04-28.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var hAccuracy: UILabel!
    @IBOutlet weak var vAccuracy: UILabel!
    @IBOutlet weak var altitude: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        startLocation = nil
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
    //        let latestLocation: CLLocation = locations[locations.count-1]
            let latestLocation: CLLocation = locations.last!
            let decimalPrecisionFormat: String = "%4f"
            
            latitude.text = String(format: decimalPrecisionFormat, latestLocation.coordinate.latitude)
            
            longitude.text = String(format: decimalPrecisionFormat, latestLocation.coordinate.longitude)
            
            hAccuracy.text = String(format: decimalPrecisionFormat, latestLocation.horizontalAccuracy)
            
            altitude.text = String(format: decimalPrecisionFormat, latestLocation.altitude)
            
            vAccuracy.text = String(format: decimalPrecisionFormat, latestLocation.verticalAccuracy)
            
            if startLocation == nil{
                startLocation = latestLocation
                
            }
            
            let distanceBetween: CLLocationDistance = latestLocation.distance(from: startLocation)
            
            distance.text = String(format: "%.2f", distanceBetween)
        
//        print("Latitude = \(latestLocation.coordinate.latitude)")
//        print("Longitude = \(latestLocation.coordinate.longitude)")
        print("Altitude = \(latestLocation.altitude)")
     
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("%@", error.localizedDescription)
    }
    
    
    
    @IBAction func resetDistance(_ sender: Any) {
        startLocation = nil
    }
    
    @IBAction func startWhenInUse(_ sender: Any) {
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.allowsBackgroundLocationUpdates = true
//        locationManager.pausesLocationUpdatesAutomatically = true
//
    }
    
    
    
    @IBAction func startAlways(_ sender: Any) {
//        locationManager.stopUpdatingLocation()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false

        
        
    }
    
    
    
    
    
    

}

