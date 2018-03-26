//
//  LoaderLauncher.swift
//  B Jazzy
//
//  Created by Gopal krishan on 24/03/18.
//  Copyright © 2018 Bull18. All rights reserved.
//

import UIKit

final class LoaderLauncher {
    private let lightBlackView = UIView()
    private let gridBackground = UIView()
    private let gridView = UIView()
    private let loaderTextView = UIView()
    
    var displayLoader = true
    
    static let sharedInstance = LoaderLauncher()
    private init(){}
    func showLoader() {
        if !displayLoader{return}
        if let window = UIApplication.shared.keyWindow {
            
            lightBlackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            window.addSubview(lightBlackView)
            lightBlackView.frame = window.frame
            lightBlackView.alpha = 0
            
            lightBlackView.addSubview(loaderTextView)
            loaderTextView.backgroundColor = UIColor(white: 0, alpha: 0.6)
            loaderTextView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loaderTextView.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                loaderTextView.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                loaderTextView.heightAnchor.constraint(equalToConstant: 100),
                loaderTextView.widthAnchor.constraint(equalToConstant: 100)
                ])
            loaderTextView.layer.cornerRadius = 50
            
            let label : UILabel = {
                let label = UILabel()
                label.text = "Loading..."
                label.textColor = .lightGray
                label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
                label.textAlignment = .center
                return label
            }()
            
            loaderTextView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: loaderTextView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: loaderTextView.centerYAnchor),
                label.heightAnchor.constraint(equalToConstant: 80),
                label.widthAnchor.constraint(equalToConstant: 80)
                ])
            
            let height: CGFloat = 50
            let y = window.frame.height - height
            gridBackground.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            gridBackground.backgroundColor = UIColor(white: 0, alpha: 0.8)
            lightBlackView.addSubview(gridBackground)
            
            gridBackground.addSubview(gridView)
            gridView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                gridView.centerXAnchor.constraint(equalTo: gridBackground.centerXAnchor),
                gridView.centerYAnchor.constraint(equalTo: gridBackground.centerYAnchor),
                gridView.heightAnchor.constraint(equalToConstant: 40),
                gridView.widthAnchor.constraint(equalToConstant: 40)
                ])
    
            GridDotsAnimation().setupAnimationInLayer(layer: gridView.layer, size: 40, tintColor: UIColor.lightGray)
            gridView.layer.speed = 2
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.lightBlackView.alpha = 1
                self.gridBackground.frame.origin.y = y
                
            }, completion: nil)
        }
    }
    
    func hideLoader() {
        displayLoader = true
        gridView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        
        UIView.animate(withDuration: 0.5) {
            self.lightBlackView.alpha = 0
            if let window = UIApplication.shared.keyWindow {
                self.gridBackground.frame.origin.y = window.frame.height
            }
        }
        lightBlackView.removeFromSuperview()
        gridBackground.removeFromSuperview()
        gridView.removeFromSuperview()
        loaderTextView.removeFromSuperview()
    }
}

class GridDotsAnimation {
    
    func setupAnimationInLayer(layer: CALayer, size: CGFloat, tintColor: UIColor) {
        
        let nbColumn = 3
        let marginBetweenDot : CGFloat = 5.0
        let dotSize = (size - (marginBetweenDot * (CGFloat(nbColumn)  - 1))) / CGFloat(nbColumn)
        
        let dot = CAShapeLayer()
        dot.frame = CGRect(
            x: 0,
            y: 0,
            width:dotSize,
            height: dotSize)
        
        dot.path = UIBezierPath(ovalIn: CGRect(x: 0, y:0, width: dotSize, height: dotSize)).cgPath
        dot.fillColor = tintColor.cgColor
        
        let replicatorLayerX = CAReplicatorLayer()
        replicatorLayerX.frame = CGRect(x: 0,y: 0,width: size,height: size)
        
        replicatorLayerX.instanceDelay = 0.3
        replicatorLayerX.instanceCount = nbColumn
        
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, dotSize+marginBetweenDot, 0, 0.0)
        replicatorLayerX.instanceTransform = transform
        
        let replicatorLayerY = CAReplicatorLayer()
        replicatorLayerY.frame = CGRect(x: 0, y: 0, width: size, height: size)
        replicatorLayerY.instanceDelay = 0.3
        replicatorLayerY.instanceCount = nbColumn
        
        var transformY = CATransform3DIdentity
        transformY = CATransform3DTranslate(transformY, 0, dotSize+marginBetweenDot, 0.0)
        replicatorLayerY.instanceTransform = transformY
        
        replicatorLayerX.addSublayer(dot)
        replicatorLayerY.addSublayer(replicatorLayerX)
        layer.addSublayer(replicatorLayerY)
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [alphaAnimation(), scaleAnimation()]
        groupAnimation.duration = 1.0
        groupAnimation.autoreverses = true
        groupAnimation.repeatCount = HUGE
        
        dot.add(groupAnimation, forKey: "groupAnimation")
    }
    
    func alphaAnimation() -> CABasicAnimation{
        let alphaAnim = CABasicAnimation(keyPath: "opacity")
        alphaAnim.fromValue = NSNumber(value: 1.0)
        alphaAnim.toValue = NSNumber(value: 0.3)
        return alphaAnim
    }
    func scaleAnimation() -> CABasicAnimation{
        let scaleAnim = CABasicAnimation(keyPath: "transform")
        
        let t = CATransform3DIdentity
        let t2 = CATransform3DScale(t, 1.0, 1.0, 0.0)
        scaleAnim.fromValue = NSValue(caTransform3D: t2)
        let t3 = CATransform3DScale(t, 0.2, 0.2, 0.0)
        scaleAnim.toValue = NSValue(caTransform3D: t3)
        
        return scaleAnim
    }
}
