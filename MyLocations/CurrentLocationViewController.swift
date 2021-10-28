//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by user206341 on 10/25/21.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var tagButton: UIButton!
    @IBOutlet var getButton: UIButton!

    let locationManager = CLLocationManager()
    var location: CLLocation?
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    var geoCoder = CLGeocoder()
    var placemarker: CLPlacemark?
    var performingReverseGeoCoding = false
    var lastGeoCodingError: Error?
    
    // Fix #2 add a timer for the whole process
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
    }
    
    // hide the navigation bar for Current Location View Controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = self.location!.coordinate
            controller.placemark = self.placemarker
        }
    }
    
    // MARK: - CLLocationManger Delegates
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError error: \(error.localizedDescription)")
        
        // unable to obtain a location, for now, maybe after a few second, it will get
        // so keep trying...
        // rawValue is the integer form of enum, CLError.locationUnknown is a enum
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            print("TAG locationManager(:didFailWithError:) keep trying...")
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        
        // 1. ignore too old location
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }

        // 2. ignore bad location, sometimes there's location has negative horizontalAccuracy
        if newLocation.horizontalAccuracy < 0 {
            return
        }
            
        // Fix #1: user cannot get enough accuracy for a long time
        // Fix #1.1: get distance of newLocation and location
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = self.location {
            distance = newLocation.distance(from: location)
        }
        
        // 3. the first time or we have enough accuracy
        //
        if self.location == nil || newLocation.horizontalAccuracy < self.location!.horizontalAccuracy {
            // clear error occured before
            lastLocationError = nil
            // store the new location
            self.location = newLocation
            
            // check the accuracy
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                // Fix #1.2: user has more accurate location
                if distance > 0 {
                    // force to do geo coding again because user's location changed
                    performingReverseGeoCoding = false
                }
                
                print("TAG Accuracy enough, we're done.")
                stopLocationManager()
        }
        
        updateLabels()
        
        // use reverse geocoding to get address
        if !performingReverseGeoCoding {
            print("TAG Start to Geo Coding...")
            geoCoder.reverseGeocodeLocation(newLocation) {placemarks,error in
//                if let err = error {
//                    print("TAG Geo decoding error: \(err.localizedDescription)")
//                    return
//                }
//
//                if let places = placemarks {
//                    print("TAG found place: \(places)")
//                    return
//                }
                self.lastGeoCodingError = error
                // normal
                if error == nil, let places = placemarks, !places.isEmpty {
                    self.placemarker = places.last!
                // some error occured
                }else {
                    self.placemarker = nil
                }
                
                self.performingReverseGeoCoding = false
                self.updateLabels()
            }
        }
            
    // not the first time, and no more accuracy
    // Fix #1.3: more than 10s, location change less than 1m
    }else if distance < 1 {
           let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
           if timeInterval > 10 {
               print("TAG Force Done")
               stopLocationManager()
               updateLabels()
           }
       }
    }

    // MARK: - Action Func
    @IBAction func getLocation() {
        // ask for permission
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            print("TAG after request authorization")
            return
        }
        
        // check the auth status
        if status == .denied || status == .restricted {
            showLocationServicesDeniedAlert()
            return
        }

        // move into func startLocationManager()
        // get location
//        print("TAG get location")
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.startUpdatingLocation()

        if updatingLocation {
            // user tapped "Stop" Button
            stopLocationManager()
        }else {
            // user tapped "Get My Location" Button
            location = nil
            lastLocationError = nil
            
            placemarker = nil
            lastGeoCodingError = nil
            
            startLocationManager()
        }
        updateLabels()
    }
    
    // MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }

    //
    func updateLabels() {
        print("TAG updateLabels()...")
        if let location = self.location {
            messageLabel.text = ""
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            
            // update label of address
            if let placemarker = self.placemarker {
                addressLabel.text = string(from: placemarker)
                
            }else if performingReverseGeoCoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeoCodingError != nil {
                addressLabel.text = "Error Finding Address"
            }else {
                addressLabel.text = "No Address found"
            }
        }else {
//            messageLabel.text = "Tap 'Get My Location' to start"
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            // show status message according to lastLocationError and other status
            let statusMsg: String?
            // error
            if let error = (lastLocationError as NSError?) {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMsg = "Location Services Diabled"
                }else {
                    statusMsg = "Error Getting Location"
                }
            // no error, maybe user disabled their whole device's locaton services
            }else if !CLLocationManager.locationServicesEnabled() {
                statusMsg = "Location Services Diabled"
            // no error, inform user the app is working
            }else if updatingLocation {
                statusMsg = "Searching..."
            // no error, haven't start yet
            }else{
                statusMsg = "Tap 'Get My Location' to start"
            }
            
            messageLabel.text = statusMsg
        }
    
        configureButton()
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let streetNumber = placemark.subThoroughfare {
            line1 += streetNumber + " "
        }
        if let street = placemark.thoroughfare {
            line1 += street
        }
        
        var line2 = ""
        if let city = placemark.locality {
            line2 += city + " "
        }
        if let state = placemark.administrativeArea {
            line2 += state + " "
        }
        if let postcode = placemark.postalCode {
            line2 += postcode
        }
        
        return line1 + "\n" + line2
    }
    
    // set button title according to if app is updating location or not
    func configureButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        }else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    // start location manager
    func startLocationManager() {
        print("TAG startLocationManager() ")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        updatingLocation = true
        
        // Fix #2.2
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                     selector: #selector(didTimeOut),
                                     userInfo: nil, repeats: false)
    }
    
    
    // stop location manager
    func stopLocationManager() {
        print("TAG stopLocationManager()")
        if updatingLocation {
            print("updating flag is: \(updatingLocation)")
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
        
        // Fix #2.3
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    // Fix #2.4
    @objc func didTimeOut() {
        if self.location == nil {
            print("TAG didTimeOut() Time out ...")
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            
            updateLabels()
        }
    }
}

