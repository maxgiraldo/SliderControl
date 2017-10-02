import Foundation
import UIKit

@IBDesignable
public class SliderControl: UIControl {
    
    // MARK: - IBInspectable Properties
    
    @IBInspectable public var rightViewBackgroundColor: UIColor = UIColor.green {
        didSet {
            rightView?.backgroundColor = rightViewBackgroundColor
        }
    }
    
    @IBInspectable public var leftViewBackgroundColor: UIColor = UIColor.green {
        didSet {
            leftView?.backgroundColor = leftViewBackgroundColor
        }
    }
    
    @IBInspectable public var rightViewText: String = ">> SLIDE TO CONTINUE" {
        didSet {
            rightViewLabel?.text = rightViewText
            rightViewLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        }
    }
    
    @IBInspectable public var leftViewImage: UIImage? = nil {
        didSet {
            leftImageView?.image = leftViewImage
        }
    }
    
    // MARK: - Private Properties
    
    private var leftView: UIView!
    private var rightView: UIView!
    private var rightViewLabel: UILabel!
    private var leftImageView: UIImageView!
    private var firstTouchPoint: CGPoint?
    
    // MARK: - Public methods
    
    public func setMainText(text: String) {
        rightViewLabel?.text = text
        rightViewLabel?.sizeToFit()
    }
    
    public func resetSlider(animated: Bool) {
        performSliderAdjustments(block: { [weak self] () -> Void in
            if let width = self?.frame.width {
                self?.rightView.frame.size.width = width
            }
            self?.rightView.frame.origin.x = 0.0
            self?.rightViewLabel?.alpha = 1.0
            },
                                 animated: animated)
    }
    
    // MARK: - Private methods
    
    // MARK: View Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpViews()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setUpViews()
        adjustViewsForOffset(offset: 50.0)
    }
    
    private func setUpViews() {
        self.layer.cornerRadius = 5.0
        self.layer.masksToBounds = true
        
        setUpLeftView()
        setUpRightView()
    }
    
    private func setUpLeftView() {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        leftView.isUserInteractionEnabled = false
        addSubview(leftView)
        
        leftView.backgroundColor = leftViewBackgroundColor
        
        setUpLeftImageView()
    }
    
    private func setUpLeftImageView() {
        leftImageView = UIImageView(frame: CGRect.zero)
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.contentMode = .scaleToFill
        
        leftView.addSubview(leftImageView)
        
        leftView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[imageView]",
                                                                               options: NSLayoutFormatOptions(rawValue: 0),
                                                                               metrics: nil,
                                                                               views: ["imageView": leftImageView]))
        
        leftView.addConstraint(NSLayoutConstraint(item: leftImageView,
                                                  attribute: NSLayoutAttribute.centerY,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: leftView,
                                                  attribute: NSLayoutAttribute.centerY,
                                                  multiplier: 1.0,
                                                  constant: 0.0))
        
        leftImageView.addConstraint(NSLayoutConstraint(item: leftImageView,
                                                       attribute: .width,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: 20.0))
        
        leftImageView.addConstraint(NSLayoutConstraint(item: leftImageView,
                                                       attribute: .height,
                                                       relatedBy: .equal,
                                                       toItem: nil,
                                                       attribute: .notAnAttribute,
                                                       multiplier: 1.0,
                                                       constant: 20.0))
        
        leftImageView.image = leftViewImage
    }
    
    private func setUpRightView() {
        rightView = UIView(frame: CGRect(x:0, y:0, width:frame.width, height:frame.height))
        
        rightView.isUserInteractionEnabled = false
        rightView.backgroundColor = rightViewBackgroundColor
        addSubview(rightView)
        
        setUpRightViewLabel()
    }
    
    private func setUpRightViewLabel() {
        rightViewLabel = UILabel(frame: rightView.frame)
        
        rightViewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rightViewLabel.text = rightViewText
        rightViewLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        rightViewLabel.textColor = UIColor.white
        
        rightView.addSubview(rightViewLabel!)
        
        rightView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[textLabel]",
                                                                                options: NSLayoutFormatOptions(rawValue: 0),
                                                                                metrics: nil,
                                                                                views: ["textLabel": rightViewLabel]))
        
        rightView.addConstraint(NSLayoutConstraint(item: rightViewLabel,
                                                   attribute: NSLayoutAttribute.centerY,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: rightView,
                                                   attribute: NSLayoutAttribute.centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        rightViewLabel.sizeToFit()
    }
    
    /*
     *  MARK: - Touch Tracking
     */
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        if touchIsInRightViewTriggerArea(touch: touch) {
            return shouldContinueTrackingTouch(touch: touch)
            
        }
        return false
    }
    
    private func touchIsInRightViewTriggerArea(touch: UITouch) -> Bool {
        let pointTouchedRightInView = touch.location(in: rightView)
        
        if pointTouchedRightInView.y >= 0 &&
            pointTouchedRightInView.y <= rightView.frame.height &&
            pointTouchedRightInView.x >= 0 &&
            pointTouchedRightInView.x <= frame.width * 0.25 {
            return true
        }
        return false
    }
    
    private func shouldContinueTrackingTouch(touch: UITouch) -> Bool {
        adjustViewsForTouch(touch: touch)
        
        if shouldTriggerEventForTouch(touch: touch) {
            handleFinalTouch(touch: touch)
            return false
        } else {
            return true
        }
    }
    
    private func adjustViewsForTouch(touch: UITouch) {
        let offset = offsetForTouch(touch: touch)
        
        adjustViewsForOffset(offset: offset)
    }
    
    private func offsetForTouch(touch: UITouch) -> CGFloat {
        let point = getTouchPoint(touch: touch)
        return point.x - firstTouchPoint!.x
    }
    
    private func getTouchPoint(touch: UITouch) -> CGPoint {
        let point = touch.location(in: self)
        if firstTouchPoint == nil {
            firstTouchPoint = point
        }
        
        return point
    }
    
    private func adjustViewsForOffset(offset: CGFloat) {
        rightViewLabel?.alpha = 1.0 - sliderPercentageForOffset(offset: offset)
        rightView.frame.origin.x = max(0, offset)
        rightView.frame.size.width = min(frame.width, frame.width - offset)
        //    leftView.frame.size.width = max(0, offset)
    }
    
    private func sliderPercentageForOffset(offset: CGFloat) -> CGFloat {
        return offset/frame.width
    }
    
    private func shouldTriggerEventForTouch(touch: UITouch) -> Bool {
        let offset = offsetForTouch(touch: touch)
        
        return offset >= frame.width * 0.75
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        if touchIsInSlider(touch: touch) {
            return shouldContinueTrackingTouch(touch: touch)
            
        }
        return false
    }
    
    private func touchIsInSlider(touch: UITouch) -> Bool {
        let point = touch.location(in: self)
        return point.x >= 0 && point.x <= self.frame.width
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        if let touch = touch {
            handleFinalTouch(touch: touch)
        }
    }
    
    private func handleFinalTouch(touch: UITouch) {
        if shouldTriggerEventForTouch(touch: touch) {
            finishSlider(animated: true)
        } else {
            resetSlider(animated: true)
        }
        
        firstTouchPoint = nil
    }
    
    private func finishSlider(animated: Bool) {
        performSliderAdjustments(block: { [weak self] () -> Void in
            self?.leftView.frame.size.width = self!.frame.width
            self?.rightView.frame.size.width = 0.0
            self?.rightView.frame.origin.x = self!.frame.width
            
            },
                                 completion: { [weak self] (finished) -> Void in
                                    self?.sendActions(for: .valueChanged)
            },
                                 animated: animated)
    }
    
    private func performSliderAdjustments(block: @escaping () -> Void,
                                          completion: ((Bool) -> Void)? = nil,
                                          animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3,
                                       delay: 0.0,
                                       usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.7,
                                       options: [.allowUserInteraction],
                                       animations: block,
                                       completion: completion)
            
        } else {
            block()
        }
        
    }
    
}