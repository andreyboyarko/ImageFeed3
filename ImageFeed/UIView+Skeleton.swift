
import UIKit

private var skeletonLayerKey: UInt8 = 0

extension UIView {
    
    private var skeletonLayer: CAGradientLayer? {
        get { return objc_getAssociatedObject(self, &skeletonLayerKey) as? CAGradientLayer }
        set { objc_setAssociatedObject(self, &skeletonLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func startSkeletonAnimation(cornerRadius: CGFloat = 0) {
        
        stopSkeletonAnimation()
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.cornerRadius = cornerRadius
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.locations = [0, 0.1, 0.3]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        
        gradient.add(animation, forKey: "skeletonAnimation")
        self.layer.addSublayer(gradient)
        self.skeletonLayer = gradient
    }
    
    func stopSkeletonAnimation() {
        skeletonLayer?.removeFromSuperlayer()
        skeletonLayer = nil
    }
}
