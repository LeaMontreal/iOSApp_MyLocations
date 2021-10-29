//
//  Hudview.swift
//  MyLocations
//
//  Created by user206341 on 10/28/21.
//

import UIKit

class HudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animation: Bool) -> HudView {
        // use the constructor with frame parameter, otherwise it maybe not display the Hud view
        // use the view.bounds(the internal dimentions of the parent view) as Hud view's frame(dimentions)
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false

        print("TAG now...")

//        hudView.backgroundColor = UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.5)
        
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96

        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: round((bounds.size.height - boxHeight)/2),
                                 width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
//        UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 0.5).setFill()
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
    }

}

