//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by user206341 on 11/2/21.
//

import Foundation
import UIKit

extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height
        
        // aspect fill
        let ratio = max(horizontalRatio, verticalRatio)
        print("TAG image size horizontalRatio = \(horizontalRatio), verticalRatio= \(verticalRatio)")
        let newWidth = min(size.width*ratio, bounds.width)
        let newHeight = min(size.height*ratio, bounds.height)
        let newSize = CGSize(width: newWidth, height: newHeight)
        print("TAG image size newSize = \(newSize.width), \(newSize.height)")
        
        // change CGPoint.zero to cut center part of the image as thumbnail ???
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func resizedFit(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width/size.width
        let verticalRatio = bounds.height/size.height

        // aspect fit
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width*ratio, height: size.height*ratio)

        //
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
