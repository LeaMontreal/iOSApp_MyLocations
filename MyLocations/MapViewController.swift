//
//  MapViewController.swift
//  MyLocations
//
//  Created by user206341 on 10/31/21.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            // simple way to do: update all locations
//            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) {_ in
//                // when view controller is loaded, then update all annotations of the locations
//                if self.isViewLoaded {
//                    self.updateLocations()
//                }
//            }

            // TODO: use the parameter notification update specific annotation instead of update all
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) {notification in
                if let dictionary = notification.userInfo {
                    print("TAG dictionary inserted \(dictionary[NSInsertedObjectsKey] ?? "NULL")")
                    print("TAG dictionary deleted \(dictionary[NSDeletedObjectsKey] ?? "NULL")")
                    print("TAG dictionary updated \(dictionary[NSUpdatedObjectsKey] ?? "NULL")")
                }

                if self.isViewLoaded {
                    self.updateLocations()
                }
            }
        }
    }
    
    var locations = [Location]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
    
    // MARK: - Help Methods
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let request = NSFetchRequest<Location>()
        
        let entity = Location.entity()
        request.entity = entity
        
        locations = try! managedObjectContext.fetch(request)
        
        mapView.addAnnotations(locations)
    }
    
    // TODO: NOT fully understand yet
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
            // there's no annotation
        case 0:
            region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            region = MKCoordinateRegion(center: annotations[0].coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topleft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topleft.latitude = max(topleft.latitude, annotation.coordinate.latitude)
                topleft.longitude = min(topleft.longitude, annotation.coordinate.longitude)

                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)

                print("TAG topleft: \(topleft.latitude),\(topleft.longitude)")
                print("TAG bottomRight: \(bottomRight.latitude),\(bottomRight.longitude)")
                print("TAG-------------------------------------------------")
            }
            
            // NOT correct like this:
//            for annotation in annotations {
//                topleft.latitude = min(topleft.latitude, annotation.coordinate.latitude)
//                topleft.longitude = max(topleft.longitude, annotation.coordinate.longitude)
//
//                bottomRight.latitude = max(bottomRight.latitude, annotation.coordinate.latitude)
//                bottomRight.longitude = min(bottomRight.longitude, annotation.coordinate.longitude)
//
//                print("TAG topleft: \(topleft.latitude),\(topleft.longitude)")
//                print("TAG bottomRight: \(bottomRight.latitude),\(bottomRight.longitude)")
//                print("TAG-------------------------------------------------")
//            }
            
            let center = CLLocationCoordinate2D(latitude: topleft.latitude + (bottomRight.latitude - topleft.latitude)/2, longitude: bottomRight.longitude + (topleft.longitude - bottomRight.longitude)/2)
            
            let extraSpace = 1.3
            let span = MKCoordinateSpan(latitudeDelta: abs(topleft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topleft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
    
    // MARK: - Actions
    @IBAction func showUser() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let adjustRegion = mapView.regionThatFits(region)
        mapView.setRegion(adjustRegion, animated: true)
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {return nil}
        
        print("TAG mapView(_:viewFor:)")
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        // create a new MKPinAnnotationView as annotationView
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(displayP3Red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        // set annotation view
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
    }
}
