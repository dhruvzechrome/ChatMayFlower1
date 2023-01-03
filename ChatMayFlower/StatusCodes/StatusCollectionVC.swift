//
//  StatusCollectionVC.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit

class StatusCollectionVC: UIViewController {
    
    
//    @IBOutlet weak var progressCollection: UICollectionView!
    @IBOutlet weak var detailsCollection: UICollectionView!
    
    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var ifc = 0
    var identifier : Int?
    var url = URL(string: "")
    var statusData = [[String:Any]]()
    var nameText = ""
    var seenStatuskey = [String]()
    var statuskey = [String]()
    var status = [String:Any]()
    var timer = Timer()
    var cnt = 1
    var counter = 0
    var int = 0
    var screenStatus = false
    var userdata = [String:Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        cnt = 0
//        progressCollection.delegate = self
//        progressCollection.dataSource = self
        detailsCollection.delegate = self
        detailsCollection.dataSource = self
//        progressBar.setProgress(0, animated: false)
//        progressBar.progressTintColor = .blue
        
        if nameText != "" {
//            name.text = "Me"
            if userdata["profilepic"] as? String != "" {
                
                let url = URL(string: "\(userdata["profilepic"] ?? "")")
//                userImage.kf.setImage(with: url)
            } else {
//                userImage.image = UIImage(systemName: "person.fill")
            }
        } else {
//            name.text = "\(userdata["Name"] ?? "")"
//            if userdata["profilepic"] as? String != "" {
//                let url = URL(string: "\(userdata["profilepic"] ?? "")")
//                userImage.kf.setImage(with: url)
//            } else {
//                userImage.image = UIImage(systemName: "person.fill")
//            }
        }
        
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screenStatus = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        seenStatuskey.removeAll()
        
    }
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    var lst = false
    var kkey :Int?
    @IBAction func forward(_ sender: UIButton) {
//        counter = 15
        lst = true
        counter = 14
//        cnt = 0
        if kkey!+1 < statusData.count {
            let indexPath = IndexPath(item: kkey!+1, section: 0)
            detailsCollection.scrollToItem(at: indexPath, at: [.bottom], animated: true)
        }
        if kkey != statusData.count-1 && counter == 15  {
            screenStatus = true
            self.dismiss(animated: true) {
            }
        }
    }
    var mycount = 0
    
}


extension StatusCollectionVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusData.count
    }

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("Yes my Guys")
        print("Index Path \(indexPath.item)")
        seenStatuskey.removeAll()
        counter = 14
        cnt = 0
        kkey = indexPath.item
        detailsCollection.scrollToItem(at: indexPath, at: [.right], animated: true)
        if ifc == 0 {
            print("yes of course")
            seenStatuskey.removeAll()
            let indexPath = IndexPath(item: identifier!, section: 0)
            detailsCollection.scrollToItem(at: indexPath, at: [.bottom], animated: true)
            ifc = 1
            counter = 0
                                identifier = nil
//                                detailsCollection.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailsCollection.dequeueReusableCell(withReuseIdentifier: "StatusDetailsCollectionCell", for: indexPath) as? StatusDetailsCollectionCell
//        if ifc == 1 {
//            ifc = 0
//            counter = 0
//            cnt = 0
//            seenStatuskey.removeAll()
//            identifier = indexPath.item
//        }
        print("cnt  \(cnt)")
        print("Index Path \(indexPath.row)")
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] _ in
//            print("Index Path \(indexPath.item)")
            if screenStatus == false {
//                print("llllolokok")
//                print("Indexpath.item ... \(indexPath.item)")
                    let frd = statusData[indexPath.item]
              
            
                let valll = frd["status"] as? [String:Any]
//                progressBar.setProgress(Float(counter*14), animated: true)
                if counter == 0 || counter == 15 {
                    
//                    print("pkpkpkpk \(seenStatuskey)")
                    //                    let frd = status
                    for i in 0...statuskey.count-1 {
                        print("statuskey is ...",statuskey[i])
                        print("\(valll?["\(statuskey[i])"])")
                        if valll?["\(statuskey[i])"]  != nil && !seenStatuskey.contains("\(statuskey[i])") {
                            
//                            let keyS = frd["statuskey"]
                            
                            let img = valll?["\(statuskey[i])"] as? [String:String]
//                            progressBar.setProgress(0, animated: false)
                            seenStatuskey.append("\(statuskey[i])")
//                            let frd = status["\(statuskey[i])"] as? [String:String]
                            print("SeenStatus key \(seenStatuskey)")
                            print("statusData\(indexPath.item) is ...",statusData[indexPath.item])
                            print("frdd is ...",frd)
                            print("statusKeys ...",statuskey)
                            print("statuskey\(i) is ...",statuskey[i])
                            url = URL(string: "\(img?["statusPhoto"] ?? "")")
                            
                            cell?.videoImage.kf.setImage(with: url)
                            counter = 0
//                            print("cnt is ---- ",cnt)
                            print("url \(url) =")
//                            if url == nil {
//                             counter = 14
//                            }
                            cnt += 1
//                            if cnt-1 > int {
//                                int += 1
//                            }
//                            videoImage.kf.setImage(with: url)
                            break
                        }
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//                    print("Counter \(Float(counter))   indexpath ...\(indexPath.item)")
//                    print("Cnt ... \(cnt)     valll.count ....\(valll?.count)")
                    counter += 1
                }
                
                
                if indexPath.item == statusData.count-1 && counter == 15 && cnt >= valll!.count {
                    screenStatus = true
                    self.dismiss(animated: true) {
                       
                    }
                }
                if indexPath.item != statusData.count-1 && counter == 15 {
                    detailsCollection.scrollToItem(at: IndexPath(item: indexPath.item+1, section: 0), at: .right, animated: true)
                    print("<L<L")
                }
                if counter >= 15 {
                    counter = 0
                    
                }
            }
        })
       
       
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cheight = UIScreen.main.bounds.height
        
        let cwidth = UIScreen.main.bounds.width
        return CGSize(width: cwidth, height: cheight)
//        let cheight = progressCollection.bounds.height
//        if status.count > 1 {
//            let ik = status.count
//            let cwidth = progressCollection.bounds.width
//            print("hight of ",cwidth)
//            print("hight of ",cheight)
//            return CGSize(width: (cwidth/CGFloat(ik))-2, height: cheight)
//        } else {
//            let cwidth = progressCollection.bounds.width
//            print("hight of ",cwidth)
//            print("hight of ",cheight)
//            return CGSize(width: cwidth, height: cheight)
//        }
        

    }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
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
