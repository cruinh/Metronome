import UIKit
import Foundation
import PlaygroundSupport

class Bubble : UIView {
    let radiusOn : CGFloat = 25.0
    let radiusOff : CGFloat = 0.0
    var pulseOn : Bool = false
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 25
        layer.backgroundColor = UIColor.cyan.cgColor
        
        createDisplayLink()
    }
    
    func createDisplayLink() {
        let displaylink = CADisplayLink(target: self,
                                        selector: #selector(step))
        
        displaylink.add(to: .current,
                        forMode: .defaultRunLoopMode)
        beatStart = Date.timeIntervalSinceReferenceDate
    }
    
    @objc func step(displaylink: CADisplayLink) {
        guard nextBeat() else { return }
        
        beatStart = Date.timeIntervalSinceReferenceDate
        
        if layer.cornerRadius == radiusOn {
            layer.cornerRadius = radiusOff
        } else {
            layer.cornerRadius = radiusOn
        }
    }
    
    var beatStart : TimeInterval? = nil
    var bpm : Double = 160
    var timePerBeat : Double {
        return 60/bpm
    }
    
    func nextBeat() -> Bool {
        guard pulseOn else { return false }
        guard let beatStart = beatStart else { return false }
        let now = Date.timeIntervalSinceReferenceDate
        let deltaTime = now - beatStart
        return (deltaTime >= timePerBeat)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 50, height: 50)
    }
}

class ViewController : UIViewController {
    let bubble = Bubble()
    let bpmLabel = UILabel(frame: .zero)
    let bpmSlider = UISlider(frame: .zero)
    let textLabel = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        
        bpmLabel.textColor = UIColor.white
        bpmLabel.text = "\(bubble.bpm)"
        
        bpmSlider.minimumValue = 0
        bpmSlider.maximumValue = 1000
        bpmSlider.value = Float(bubble.bpm)
        bpmSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(togglePulse))
        view.addGestureRecognizer(tapper)
        view.isUserInteractionEnabled = true
        
        textLabel.textColor = UIColor.white
        textLabel.text = "Tap to toggle"
        textLabel.textAlignment = .center
    }
    
    @objc func togglePulse() {
        bubble.pulseOn = !bubble.pulseOn
    }
    
    private func setLayout() {
        bpmLabel.translatesAutoresizingMaskIntoConstraints = false
        bpmSlider.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bubble)
        view.addSubview(bpmLabel)
        view.addSubview(bpmSlider)
        view.addSubview(textLabel)
        
        view.addConstraint(NSLayoutConstraint(item: bubble, attribute: .centerX, relatedBy: .equal, toItem:view , attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bubble, attribute: .centerY, relatedBy: .equal, toItem:view , attribute: .centerY, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bpmLabel, attribute: .centerX, relatedBy: .equal, toItem:view , attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[bpmLabel]", options: [], metrics: nil, views: ["bpmLabel":bpmLabel]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[bpmSlider]-16-|", options: [], metrics: nil, views: ["bpmSlider":bpmSlider]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bpmLabel]-8-[bpmSlider]", options: [], metrics: nil, views: ["bpmLabel":bpmLabel, "bpmSlider":bpmSlider]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[textLabel]-16-|", options: [], metrics: nil, views: ["textLabel":textLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[textLabel]-8-|", options: [], metrics: nil, views: ["bpmLabel":bpmLabel, "bpmSlider":bpmSlider,"textLabel":textLabel]))
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let incrementValue = (roundf(sender.value / 10.0)) * 10.0
        sender.setValue(incrementValue, animated: false)
        bubble.bpm = Double(sender.value)
        bpmLabel.text = "\(bubble.bpm)"
    }
}

PlaygroundPage.current.liveView = ViewController()
