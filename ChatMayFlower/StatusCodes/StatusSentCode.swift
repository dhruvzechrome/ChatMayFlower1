//
//  StatusSentCodeViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 26/12/22.
//

import UIKit

class StatusSentCode: UIViewController {
    
    var image = UIImage()
    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
        // Do any additional setup after loading the view.
    }
    

    @IBAction func sentStatus(_ sender: UIButton) {
    }
    @IBAction func dismiss(_ sender: UIButton) {
    }
    
}

extension StatusSentCode {
    @objc fileprivate func onDrag(_ sender: UIPanGestureRecognizer) {

            let translation = sender.translation(in: view)

            // Movement indication index
            let movementOnAxis: CGFloat

            // Move view to new position
            switch axis {
            case .vertical:
                let newY = min(max(view.frame.minY + translation.y, 0), view.frame.maxY)
                movementOnAxis = newY / view.bounds.height
                view.frame.origin.y = newY

            case .horizontal:
                let newX = min(max(view.frame.minX + translation.x, 0), view.frame.maxX)
                movementOnAxis = newX / view.bounds.width
                view.frame.origin.x = newX
            @unknown default:
                fatalError()
            }

            let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            let progress = CGFloat(positiveMovementOnAxisPercent)
        navigationController?.view.backgroundColor = .clear

            switch sender.state {
            case .ended where sender.velocity(in: view).y >= velocityDismiss || progress > percentThresholdDismiss:
                // After animate, user made the conditions to leave
                UIView.animate(withDuration: 0.2, animations: {
                    switch self.axis {
                    case .vertical:
                        self.view.frame.origin.y = self.view.bounds.height

                    case .horizontal:
                        self.view.frame.origin.x = self.view.bounds.width
                    @unknown default:
                        fatalError()
                    }
                    self.navigationController?.view.backgroundColor = .clear

                }, completion: { finish in
                    self.dismiss(animated: true) //Perform dismiss
                })
            case .ended:
                // Revert animation
                UIView.animate(withDuration: 0.2, animations: {
                    switch self.axis {
                    case .vertical:
                        self.view.frame.origin.y = 0

                    case .horizontal:
                        self.view.frame.origin.x = 0
                    @unknown default:
                        fatalError()
                    }
                })
            default:
                break
            }
            sender.setTranslation(.zero, in: view)
        }
}
