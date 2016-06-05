import Foundation
import UIKit

@IBDesignable
public class SliderControl: UIControl {
  
  // MARK: - IBInspectable Properties
  
  @IBInspectable public var rightViewBackgroundColor: UIColor = Colors.green {
    didSet {
      rightView?.backgroundColor = rightViewBackgroundColor
    }
  }
  
  @IBInspectable public var leftViewBackgroundColor: UIColor = Colors.darkGreen {
    didSet {
      leftView?.backgroundColor = leftViewBackgroundColor
    }
  }
  
  @IBInspectable public var rightViewText: String = ">> SLIDE TO CONTINUE" {
    didSet {
      rightViewLabel?.text = rightViewText
      rightViewLabel?.font = UIFont(name: Fonts.sharedResource.GothamMedium, size: 18.0)
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
    performSliderAdjustments({ [weak self] () -> Void in
      self?.rightView.frame.size.width = self!.frame.width
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
    adjustViewsForOffset(50.0)
  }
  
  private func setUpViews() {
    self.layer.cornerRadius = 5.0
    self.layer.masksToBounds = true
    
    setUpLeftView()
    setUpRightView()
  }
  
  private func setUpLeftView() {
    leftView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
    leftView.userInteractionEnabled = false
    addSubview(leftView)
    
    leftView.backgroundColor = leftViewBackgroundColor
    
    setUpLeftImageView()
  }
  
  private func setUpLeftImageView() {
    leftImageView = UIImageView(frame: CGRectZero)
    
    leftImageView.translatesAutoresizingMaskIntoConstraints = false
    leftImageView.contentMode = .ScaleToFill
    
    leftView.addSubview(leftImageView)
    
    leftView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[imageView]",
      options: NSLayoutFormatOptions(rawValue: 0),
      metrics: nil,
      views: ["imageView": leftImageView]))
    
    leftView.addConstraint(NSLayoutConstraint(item: leftImageView,
      attribute: NSLayoutAttribute.CenterY,
      relatedBy: NSLayoutRelation.Equal,
      toItem: leftView,
      attribute: NSLayoutAttribute.CenterY,
      multiplier: 1.0,
      constant: 0.0))
    
    leftImageView.addConstraint(NSLayoutConstraint(item: leftImageView,
      attribute: .Width,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: 20.0))
    
    leftImageView.addConstraint(NSLayoutConstraint(item: leftImageView,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: nil,
      attribute: .NotAnAttribute,
      multiplier: 1.0,
      constant: 20.0))
    
    leftImageView.image = leftViewImage
  }
  
  private func setUpRightView() {
    rightView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
    
    rightView.userInteractionEnabled = false
    rightView.backgroundColor = rightViewBackgroundColor
    addSubview(rightView)
    
    setUpRightViewLabel()
  }
  
  private func setUpRightViewLabel() {
    rightViewLabel = UILabel(frame: rightView.frame)
    
    rightViewLabel.translatesAutoresizingMaskIntoConstraints = false
    
    rightViewLabel.text = rightViewText
    rightViewLabel?.font = UIFont(name: Fonts.sharedResource.GothamMedium, size: 18.0)
    rightViewLabel.textColor = UIColor.whiteColor()
    
    rightView.addSubview(rightViewLabel!)
    
    rightView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[textLabel]",
      options: NSLayoutFormatOptions(rawValue: 0),
      metrics: nil,
      views: ["textLabel": rightViewLabel]))
    
    rightView.addConstraint(NSLayoutConstraint(item: rightViewLabel,
      attribute: NSLayoutAttribute.CenterY,
      relatedBy: NSLayoutRelation.Equal,
      toItem: rightView,
      attribute: NSLayoutAttribute.CenterY,
      multiplier: 1.0,
      constant: 0.0))
    
    rightViewLabel.sizeToFit()
  }
  
  /*
  *  MARK: - Touch Tracking
  */
  
  override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    super.beginTrackingWithTouch(touch, withEvent: event)
    
    if touchIsInRightViewTriggerArea(touch) {
      return shouldContinueTrackingTouch(touch)
      
    }
    return false
  }
  
  private func touchIsInRightViewTriggerArea(touch: UITouch) -> Bool {
    let pointTouchedRightInView = touch.locationInView(rightView)
    
    if pointTouchedRightInView.y >= 0 &&
      pointTouchedRightInView.y <= rightView.frame.height &&
      pointTouchedRightInView.x >= 0 &&
      pointTouchedRightInView.x <= frame.width * 0.25 {
        return true
    }
    return false
  }
  
  private func shouldContinueTrackingTouch(touch: UITouch) -> Bool {
    adjustViewsForTouch(touch)
    
    if shouldTriggerEventForTouch(touch) {
      handleFinalTouch(touch)
      return false
    } else {
      return true
    }
  }
  
  private func adjustViewsForTouch(touch: UITouch) {
    let offset = offsetForTouch(touch)
    
    adjustViewsForOffset(offset)
  }
  
  private func offsetForTouch(touch: UITouch) -> CGFloat {
    let point = getTouchPoint(touch)
    return point.x - firstTouchPoint!.x
  }
  
  private func getTouchPoint(touch: UITouch) -> CGPoint {
    let point = touch.locationInView(self)
    if firstTouchPoint == nil {
      firstTouchPoint = point
    }
    
    return point
  }
  
  private func adjustViewsForOffset(offset: CGFloat) {
    rightViewLabel?.alpha = 1.0 - sliderPercentageForOffset(offset)
    rightView.frame.origin.x = max(0, offset)
    rightView.frame.size.width = min(frame.width, frame.width - offset)
    //    leftView.frame.size.width = max(0, offset)
  }
  
  private func sliderPercentageForOffset(offset: CGFloat) -> CGFloat {
    return offset/frame.width
  }
  
  private func shouldTriggerEventForTouch(touch: UITouch) -> Bool {
    let offset = offsetForTouch(touch)
    
    return offset >= frame.width * 0.75
  }
  
  override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    super.continueTrackingWithTouch(touch, withEvent: event)
    
    if touchIsInSlider(touch) {
      return shouldContinueTrackingTouch(touch)
      
    }
    return false
  }
  
  private func touchIsInSlider(touch: UITouch) -> Bool {
    let point = touch.locationInView(self)
    return point.x >= 0 && point.x <= self.frame.width
  }
  
  override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
    super.endTrackingWithTouch(touch, withEvent: event)
    
    if let touch = touch {
      handleFinalTouch(touch)
    }
  }
  
  private func handleFinalTouch(touch: UITouch) {
    if shouldTriggerEventForTouch(touch) {
      finishSlider(true)
    } else {
      resetSlider(true)
    }
    
    firstTouchPoint = nil
  }
  
  private func finishSlider(animated: Bool) {
    performSliderAdjustments({ [weak self] () -> Void in
      self?.leftView.frame.size.width = self!.frame.width
      self?.rightView.frame.size.width = 0.0
      self?.rightView.frame.origin.x = self!.frame.width
      
      },
      completion: { [weak self] (finished) -> Void in
        self?.sendActionsForControlEvents(.ValueChanged)
      },
      animated: animated)
  }
  
  private func performSliderAdjustments(block: () -> Void,
    completion: ((Bool) -> Void)? = nil,
    animated: Bool) {
      if animated {
        UIView.animateWithDuration(0.3,
          delay: 0.0,
          usingSpringWithDamping: 0.5,
          initialSpringVelocity: 0.7,
          options: [.AllowUserInteraction],
          animations: block,
          completion: completion)
        
      } else {
        block()
      }
      
  }
  
}