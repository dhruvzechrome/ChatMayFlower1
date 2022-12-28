//
//  StatusCollectionVC.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit

class StatusCollectionVC: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    var seenStatuskey = [String]()
    var statuskey = [String]()
    var status = [String:Any]()
    var timer = Timer()
    var cnt = 0
    var counter = 0
    
    var screenStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.setProgress(0, animated: false)
        progressBar.progressTintColor = .blue
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
                if screenStatus == false {
                    progressBar.setProgress(Float(counter*14), animated: true)
                    if counter == 0 || counter == 15 {
                        //                    let frd = status
                        for i in 0...statuskey.count-1 {
                            if status["\(statuskey[i])"]  != nil && !seenStatuskey.contains("\(statuskey[i])") {
                                progressBar.setProgress(0, animated: false)
                                seenStatuskey.append("\(statuskey[i])")
                                let frd = status["\(statuskey[i])"] as? [String:String]
                                let url = URL(string: frd?["statusPhoto"] ?? "")
                                counter = 0
                                cnt += 1
                                videoImage.kf.setImage(with: url)
                                break
                            }
                        }
                    }
                    print("Counter \(Float(counter))")
                    counter += 1
                    if cnt == status.count && counter == 16{
                        screenStatus = true
                        self.dismiss(animated: true) {
                            
                        }
                    }
                }
            })
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenStatus = true
    }
//    func segmentedProgressBarChangedIndex(index: Int) {
//        <#code#>
//    }
//
//    func segmentedProgressBarFinished() {
//        <#code#>
//    }
//
//    var SPB: SegmentedProgressBar!
//    override func viewDidLoad() {
//        SPB = SegmentedProgressBar(numberOfSegments: status.count, duration: 5)
//        if #available(iOS 11.0, *) {
//            SPB.frame = CGRect(x: 18, y: UIApplication.shared.statusBarFrame.height + 5, width: view.frame.width - 35, height: 3)
//        } else {
//            // Fallback on earlier versions
//            SPB.frame = CGRect(x: 18, y: 15, width: view.frame.width - 35, height: 3)
//        }
//
//        SPB.delegate = self
//        SPB.topColor = UIColor.white
//        SPB.bottomColor = UIColor.white.withAlphaComponent(0.25)
//        SPB.padding = 2
//        SPB.isPaused = true
//        SPB.currentAnimationIndex = 0
////        SPB.duration = getDuration(at: 0)
//        view.addSubview(SPB)
//        view.bringSubviewToFront(SPB)
//    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
