//
//  KeyboardSettings.swift
//  Sweety
//
//  Created by Burak İmdat on 24.11.2021.
//

import Foundation
import UIKit

extension UIView {
    func setKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(setKeyboardLocation(_ :)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func setKeyboardLocation(_ notification: NSNotification){
        let time = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let firstFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let lastFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let diffY = lastFrame.origin.y - firstFrame.origin.y
        
        UIView.animateKeyframes(withDuration: time, delay: 0, options: KeyframeAnimationOptions(rawValue: curve), animations: {
                self.frame.origin.y += diffY
            }, completion: nil)
    }
}
