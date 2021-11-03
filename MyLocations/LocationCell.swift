//
//  LocationCell.swift
//  MyLocations
//
//  Created by user206341 on 10/31/21.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(for location: Location) {
        if location.locationDescription.isEmpty {
            self.descriptionLabel.text = "(No Description)"
        }else {
            self.descriptionLabel.text = location.locationDescription
        }
        
        var address = ""
        if let placemark = location.placemark {
            if let tmp = placemark.subThoroughfare {
                address += tmp + " "
            }
            if let tmp = placemark.thoroughfare {
                address += tmp + ","
            }
            if let tmp = placemark.locality {
                address += tmp
            }

        }else {
            address = String(format: "%.8f %.8f", location.latitude, location.longitude)
        }
        
        self.addressLabel.text = address
        
        // display thumbnail image
        photoImageView.image = thumbnail(for: location)
        print("TAG thumbnail size is: \(photoImageView.image!.size.width), \(photoImageView.image!.size.height)")
    }
    
    // get a UIImage for location
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let theImage = location.photoImage {
            return theImage.resized(withBounds: CGSize(width: 52, height: 52))
        }
        
        return UIImage()
    }
}
