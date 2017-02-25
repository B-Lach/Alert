//
//  Alert.swift
//  AlertTest
//
//  Created by Benny Lach on 18.12.16.
//  Copyright © 2016 Benny Lach. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit

private struct Colors {
    static let success: UIColor = UIColor(red: 98/255, green: 185/255, blue: 127/255, alpha: 0.7)
    static let warning: UIColor = UIColor.orange.withAlphaComponent(0.7)
    static let error: UIColor = UIColor.red.withAlphaComponent(0.7)
}

public class Alert: UIView {
    fileprivate var titleLabel: UILabel!
    fileprivate var messageLabel: UILabel!
    fileprivate var actionClosure: (() -> ())?
    
    public static func showWarning(title: String, message: String, duration: Double = 3.0, animated: Bool = true, actionClosure: (() -> ())? = nil, completion: (() -> ())? = nil ) {
        let alertView = Alert(title: title,
                              message: message,
                              textColor: .white,
                              backgroundColor: Colors.warning,
                              actionClosure: actionClosure)
        
        alertView.showAlert(duration: duration, animated: animated, completion: completion)
    }
    
    public static func showError(title: String, message: String, duration: Double = 3.0, animated: Bool = true,actionClosure: (() -> ())? = nil, completion: (() -> ())? = nil ) {
        let alertView = Alert(title: title,
                              message: message,
                              textColor: .white,
                              backgroundColor: Colors.error,
                              actionClosure: actionClosure)
        
        alertView.showAlert(duration: duration, animated: animated, completion: completion)
    }
    
    public static func showSuccess(title: String, message: String, duration: Double = 3.0, animated: Bool = true, actionClosure: (() -> ())? = nil, completion: (() -> ())? = nil ) {
        let alertView = Alert(title: title,
                              message: message,
                              textColor: .white,
                              backgroundColor: Colors.success,
                              actionClosure: actionClosure)
        
        alertView.showAlert(duration: duration, animated: animated, completion: completion)
    }
    
    public static func showCustomAlert(title: String, message: String, textColor: UIColor, backgroundColor: UIColor, duration: Double = 3.0, animated: Bool = true, actionClosure: (() -> ())? = nil, completion: (() -> ())? = nil ) {
        let alertView = Alert(title: title,
                              message: message,
                              textColor: textColor,
                              backgroundColor: backgroundColor,
                              actionClosure: actionClosure)
        
        alertView.showAlert(duration: duration, animated: animated, completion: completion)
    }
}

// MARK: - Animations
fileprivate extension Alert {
    fileprivate func showAlert(duration: Double, animated: Bool, completion: (() -> ())? ) {
        if let vc = UIApplication.topViewController() {
            let deltaY: CGFloat = (vc.navigationController != nil ? 64.0 : 0.0) + vc.view.bounds.origin.y
            isHidden = true
            
            vc.view.addSubview(self)
            
            addViewConstraints(top: deltaY, left: 10.0, superView: vc.view)
            forceLayoutUpdate()
            
            if animated {
                showAnimation(deltaY: deltaY, completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                        self.hideAnimation(completion: completion)
                    })
                })
                
                
            } else {
                isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                    self.removeFromSuperview()
                    completion?()
                })
            }
            
        } else { completion?() }
    }
    
    private func showAnimation(deltaY: CGFloat, completion: @escaping () -> ()) {
        isHidden = false
        
        self.layer.add(bounceAnimation(deltaY: deltaY), forKey: "bounce")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion()
        }
    }
    
    private func bounceAnimation(deltaY: CGFloat) -> CAKeyframeAnimation {
        let delta = deltaY + abs(frame.origin.y)
        
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [0, delta, delta / 1.3, delta, delta / 1.1, delta]
        animation.keyTimes = [0.0, 0.3, 0.5, 0.65, 0.8, 0.95]
        animation.duration = CFTimeInterval(animation.keyTimes!.last!)
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    private func hideAnimation(completion: (() -> ())? ) {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: self.frame.height * -1)
            self.setNeedsLayout()
        }, completion: { (_) in
            self.isHidden = true
            completion?()
        })
    }
}

// MARK: - View Constraints
fileprivate extension Alert {
    fileprivate convenience init(title: String, message: String, textColor: UIColor, backgroundColor: UIColor, actionClosure: (() -> ())?) {
        self.init(frame: .zero)
        
        
        setup(backgroundColor: backgroundColor, textColor: textColor, title: title, message: message)
        
        self.backgroundColor = backgroundColor
        self.actionClosure = actionClosure
    }
    
    fileprivate func addViewConstraints(top: CGFloat, left: CGFloat, superView: UIView) {
        let topConstraint = NSLayoutConstraint(item: self,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: superView,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: top)
        
        let leftConstraint = NSLayoutConstraint(item: self,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: superView,
                                                attribute: .leading,
                                                multiplier: 1.0,
                                                constant: left)
        
        NSLayoutConstraint.activate([topConstraint, leftConstraint])
    }
    
    private func setup(backgroundColor: UIColor, textColor: UIColor, title: String, message: String) {
        
        // MARK: - Title Label setup
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = textColor
        titleLabel.text = title
        
        addSubview(titleLabel)
        
        let ttlLeading = NSLayoutConstraint(item: titleLabel,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .leading,
                                            multiplier: 1.0,
                                            constant: 10)
        
        let ttlTrailing = NSLayoutConstraint(item: titleLabel,
                                             attribute: .trailing,
                                             relatedBy: .lessThanOrEqual,
                                             toItem: self,
                                             attribute: .trailing,
                                             multiplier: 1.0,
                                             constant: 10)
        
        let ttlTop = NSLayoutConstraint(item: titleLabel,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: 5)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Message Label setup
        messageLabel = UILabel(frame: .zero)
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = textColor
        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.sizeToFit()
        
        addSubview(messageLabel)
        
        let msgLeading = NSLayoutConstraint(item: messageLabel,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .leading,
                                            multiplier: 1.0,
                                            constant: 10)
        
        let msgTrailing = NSLayoutConstraint(item: messageLabel,
                                             attribute: .trailing,
                                             relatedBy: .lessThanOrEqual,
                                             toItem: self,
                                             attribute: .trailing,
                                             multiplier: 1.0,
                                             constant: 10)
        
        let msgTop = NSLayoutConstraint(item: messageLabel,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: titleLabel,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 5)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - View Setup
        let viewBottom = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: messageLabel,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 10)
        
        let viewWidth = NSLayoutConstraint(item: self,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: nil,
                                           attribute: .width,
                                           multiplier: 1.0,
                                           constant: UIScreen.main.bounds.width - 20)
        
        // MARK: - Action Button
        let actionButton = UIButton()
        actionButton.addTarget(self, action: #selector(Alert.buttonTouched), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.layer.masksToBounds = true
        
        addSubview(actionButton)
        
        let btnTop = NSLayoutConstraint(item: actionButton,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: self,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: 0)
        
        let btnLeading = NSLayoutConstraint(item: actionButton,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: self,
                                            attribute: .leading,
                                            multiplier: 1.0,
                                            constant: 0)
        
        let btnTrailing = NSLayoutConstraint(item: actionButton,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .trailing,
                                             multiplier: 1.0,
                                             constant: 0)
        
        let btnBottom = NSLayoutConstraint(item: actionButton,
                                           attribute: .bottom,
                                           relatedBy: .equal,
                                           toItem: self,
                                           attribute: .bottom,
                                           multiplier: 1.0,
                                           constant: 0)
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([ttlLeading,
                                     ttlTop,
                                     ttlTrailing,
                                     msgLeading,
                                     msgTop,
                                     msgTrailing,
                                     viewWidth,
                                     viewBottom,
                                     btnTop,
                                     btnLeading,
                                     btnTrailing,
                                     btnBottom])
        
        forceLayoutUpdate()
    }
    
    fileprivate func forceLayoutUpdate() {
        setNeedsLayout()
        layoutIfNeeded()
    }
}

fileprivate extension Alert {
    @objc fileprivate func buttonTouched() {
        actionClosure?()
    }
}

// MARK: - Bottom corners only
public extension Alert {
    public override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 5, height: 5))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path  = maskPath.cgPath
        layer.mask = maskLayer
    }
}

// MARK: - Get the top most view controller of the hierarchy
fileprivate extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


