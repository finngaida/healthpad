//
//  Loader.swift
//  
//
//  Created by Finn Gaida on 16.03.16.
//
//

import Foundation
import UIKit
import SwitchLoader
import Async
import ActionKit

class Loader: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 15
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func showLoader(onVC: UIViewController) {
        
        let bg = UIView(frame: onVC.view.frame)
        bg.backgroundColor = UIColor.blackColor()
        bg.alpha = 0
        bg.tag = 456
        
        let hide = UIButton(frame: bg.frame)
        hide.addControlEvent(.TouchUpInside) { () -> () in
            Loader.hideLoader(onVC)
        }
        bg.addSubview(hide)
        
        let loader = Loader(frame: CGRectMake(0, 0, 200, 200))
        loader.tag = 456
        
        let anim = RPLoadingAnimationView(frame: loader.frame, type: RPLoadingAnimationType.RotatingCircle, color: UIColor.blackColor(), size: loader.frame.size)
        loader.addSubview(anim)
        anim.setupAnimation()
        
        loader.center = CGPointMake(onVC.view.frame.width / 2, -250)
        
        Async.main { () -> Void in
            onVC.view.addSubview(bg)
            onVC.view.addSubview(loader)
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                bg.alpha = 0.6
                loader.center = onVC.view.center
                }) { (success) -> Void in
                    
            }
        }
        
    }
    
    class func hideLoader(onVC: UIViewController) {
        
        onVC.view.subviews.forEach { (loader) -> () in
            if loader.tag == 456 {
                Async.main { () -> Void in
                    UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                        loader.center = CGPointMake(loader.center.x, (loader.superview?.frame.height)! + loader.frame.height)
                        }) { (success) -> Void in
                            loader.removeFromSuperview()
                    }
                }
            }
        }
    }
    
}
