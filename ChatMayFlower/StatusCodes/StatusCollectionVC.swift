//
//  StatusCollectionVC.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit

class StatusCollectionVC: UIViewController,SegmentedProgressBarDelegate {
    var status = [String:Any]()
    func segmentedProgressBarChangedIndex(index: Int) {
        <#code#>
    }
    
    func segmentedProgressBarFinished() {
        <#code#>
    }
    
    var SPB: SegmentedProgressBar!
    override func viewDidLoad() {
        SPB = SegmentedProgressBar(numberOfSegments: status.count, duration: 5)
        if #available(iOS 11.0, *) {
            SPB.frame = CGRect(x: 18, y: UIApplication.shared.statusBarFrame.height + 5, width: view.frame.width - 35, height: 3)
        } else {
            // Fallback on earlier versions
            SPB.frame = CGRect(x: 18, y: 15, width: view.frame.width - 35, height: 3)
        }
        
        SPB.delegate = self
        SPB.topColor = UIColor.white
        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
        SPB.padding = 2
        SPB.isPaused = true
        SPB.currentAnimationIndex = 0
//        SPB.duration = getDuration(at: 0)
        view.addSubview(SPB)
        view.bringSubviewToFront(SPB)
    }
}
