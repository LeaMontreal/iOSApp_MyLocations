//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by user206341 on 10/30/21.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    public var title: String? {
        if locationDescription.isEmpty {
            return "(No Description)"
        }else {
            return locationDescription
        }
    }
    
    public var subtitle: String? {
        return category
    }

    // get state whether location has photo
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    // get photo's full file path
    var photoURL: URL {
        // assert(<#T##condition: Bool##Bool#>, <#T##message: String##String#>), assert condition is true, otherwise, print message
        assert(photoID != nil, "No Photo ID set")
        
        let filename = "PHOTO-\(photoID!.intValue).jpg"
        return applicationDocumentDirectory.appendingPathComponent(filename)
    }
    
    // get a UIImage object from photo's filename
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    // get next photo ID
    class func nextPhotoID() -> Int {
        let currentID = UserDefaults.standard.integer(forKey: "PhotoID") + 1
        UserDefaults.standard.set(currentID, forKey: "PhotoID")
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
                print("TAG remove photo file at \(photoURL.path)")
            }catch {
                print("Error removing file: \(error)")
            }
        }
    }
}
