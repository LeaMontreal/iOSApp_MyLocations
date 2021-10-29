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
        
        // draw image
        // use if unwrap optional image or use guard unwrap
//        if let image = UIImage(named: "Checkmark") {
//            let point = CGPoint(x: center.x - round(image.size.width/2), y: center.y - round(image.size.height/2 + boxHeight/8))
//            image.draw(at: point)
//
//        }

        // use if unwrap optional image or use guard unwrap
        guard let image = UIImage(named: "Checkmark") else {return}
        let point = CGPoint(x: center.x - round(image.size.width/2),
                            y: center.y - round(image.size.height/2 + boxHeight/8))
        image.draw(at: point)
        
        // draw text
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                          NSAttributedString.Key.foregroundColor: UIColor.white]
        let textSize = text.size(withAttributes: attributes)
        let textPoint = CGPoint(x: center.x - round(textSize.width/2), y: center.y - round(textSize.height/2 - boxHeight/4))
        text.draw(at: textPoint, withAttributes: attributes)
    }
    
    // MARK: - Helper Methods
    func show(animation animated: Bool) {
        if animated {
            // initial state
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            // final state
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            })
        }
    }
    
    func showSpringAnimation(animation animated: Bool) {
        if animated {
            // initial state
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            // final state
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
                           options: [],
                           animations: {
                            self.alpha = 1
                            self.transform = CGAffineTransform.identity
                           },
                           completion: nil)
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }

}

