//
//  StatusCollectionVC.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit

class StatusCollectionVC: UIViewController {
    
    
    @IBOutlet weak var progressCollection: UICollectionView!
    
    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    var nameText = ""
    var seenStatuskey = [String]()
    var statuskey = [String]()
    var status = [String:Any]()
    var timer = Timer()
    var cnt = 0
    var counter = 0
    var int = 0
    var screenStatus = false
    var userdata = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        progressCollection.delegate = self
        progressCollection.dataSource = self
//        progressBar.setProgress(0, animated: false)
//        progressBar.progressTintColor = .blue
        if nameText != "" {
            name.text = "Me"
            if userdata["profilepic"] as? String != "" {
                let url = URL(string: "\(userdata["profilepic"] ?? "")")
                userImage.kf.setImage(with: url)
            } else {
                userImage.image = UIImage(systemName: "person.fill")
            }
        } else {
            name.text = userdata["Name"] as? String
            if userdata["profilepic"] as? String != "" {
                let url = URL(string: "\(userdata["profilepic"] ?? "")")
                userImage.kf.setImage(with: url)
            } else {
                userImage.image = UIImage(systemName: "person.fill")
            }
        }
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if screenStatus == false {
//                progressBar.setProgress(Float(counter*14), animated: true)
                if counter == 0 || counter == 15 || lst == true{
                    //                    let frd = status
                    for i in 0...statuskey.count-1 {
                        if status["\(statuskey[i])"]  != nil && !seenStatuskey.contains("\(statuskey[i])") {
                         
//                            progressBar.setProgress(0, animated: false)
                            seenStatuskey.append("\(statuskey[i])")
                            let frd = status["\(statuskey[i])"] as? [String:String]
                            let url = URL(string: frd?["statusPhoto"] ?? "")
                            counter = 0
                            print("cnt is ---- ",cnt)
                            cnt += 1
                            if cnt-1 > int {
                                int += 1
                            }
                            videoImage.kf.setImage(with: url)
                            break
                        }
                    }
                }
//                print("Counter \(Float(counter))")
                counter += 1
                if cnt == status.count && counter == 16{
                    screenStatus = true
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        })
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenStatus = true
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    var lst = false
    var kkey :Int?
    @IBAction func forward(_ sender: UIButton) {
        counter = 15
        lst = true
        kkey = int
        print("KKey \(kkey)")
    }
    var mycount = 0
    
}


extension StatusCollectionVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = progressCollection.dequeueReusableCell(withReuseIdentifier: "StatusCollectionVCCell", for: indexPath) as? StatusCollectionVCCell
//        print("int ==== \(int)   --- cnt ",cnt)
        cell?.progressBarC.setProgress(0, animated: true)
        cell?.progressBarC.progressTintColor = .tintColor
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
            if screenStatus == false {
                print("My counting is \(mycount)")
                mycount += 1
                if  indexPath.row == 0 && lst == true{
                    print("---- int \(int)---- kkey \(kkey) --- indexpath \(indexPath.row)")
                    cell?.progressBarC.setProgress(100, animated: false)
                    //                kkey = nil
                    //                    lst = false
                }
                else if indexPath.row == int {
                    print("int \(int) ---* indexpath \(indexPath.row)")
                    
                    cell?.progressBarC.setProgress(Float(counter*15), animated: true)
                    
                    
                } else {
                    //cell?.progressBarC.setProgress(100, animated: true)
                }
            }
            
        })
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cheight = progressCollection.bounds.height
        if status.count > 1 {
            let ik = status.count
            let cwidth = progressCollection.bounds.width
            print("hight of ",cwidth)
            print("hight of ",cheight)
            return CGSize(width: (cwidth/CGFloat(ik))-2, height: cheight)
        } else {
            let cwidth = progressCollection.bounds.width
            print("hight of ",cwidth)
            print("hight of ",cheight)
            return CGSize(width: cwidth, height: cheight)
        }
        

    }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 2
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
       }
}

extension StatusCollectionVC {
    
    //    public var backgroundDismissColor: UIColor = .clear {
//            didSet {
//                navigationController?.view.backgroundColor = backgroundDismissColor
//            }
//        }
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
