//
//  StatusCollectionVC.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class StatusCollectionVC: UIViewController,UIContextMenuInteractionDelegate {
    var stack = UIStackView()
    var progressViews = [UIProgressView()]
//    @IBOutlet weak var progressCollection: UICollectionView!
    @IBOutlet weak var detailsCollection: UICollectionView!
    
    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    
    let favorite = UIAction(title: "Delete",
                            image: UIImage(systemName: "trash.circle.fill")) { [self] _ in
        // Perform actio
        
        StatusCollectionVC().alertView()
    }
    func alertView(){
        let alert = UIAlertController(title: "", message: "Are you sure for delete!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self]_ in
            delete()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func delete() {
        let ref = Database.database().reference().child("Contact List")
        ref.child("\(phones)").child("status").setValue(nil)
        ref.child("\(phones)").setValue(["statusKey" : nil])
    }
    var databaseRef: DatabaseReference!
    var phones = ""
    var ifc = 0
    var identifier : Int?
    var url = URL(string: "")
    var statusData = [[String:Any]]()
    var nameText = ""
    var seenStatuskey = [String]()
    var statuskey = [String]()
    var timer = Timer()
    var counter = 0
    var screenStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        detailsCollection.delegate = self
        detailsCollection.dataSource = self
        stack.frame = CGRect(x: 5, y: 38, width: view.frame.width-10, height: 5)
        stack.axis = .horizontal
        stack.spacing = 5
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        view.addSubview(stack)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.screenStatus == false {
                self.counter += 1
                print("Count \(self.counter)")
                
                if self.progressViews.count > 1 {
                    
                    for i in 0...self.progressViews.count-1 {
                         if i == self.statuscount {
                            self.progressViews[self.statuscount].setProgress(Float(self.counter*4), animated: true)
                        }
                    }
                    
                    
                    print("statucount \(self.statuscount)")
                } else {
                    self.progressViews[0].setProgress(Float(self.counter*4), animated: true)
                }
                if self.counter == 5 {
                    self.detailsCollection.reloadData()
                    self.localBool = true
                    self.statuscount += 1
                    self.counter = 0
                }
            }
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
        if nameText == "You" {
            alertView()
        } else {
//            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
          configurationForMenuAtLocation location: CGPoint)
          -> UIContextMenuConfiguration? {

          let favorite = UIAction(title: "Favorite",
            image: UIImage(systemName: "heart.fill")) { _ in
            // Perform action
          }

          let share = UIAction(title: "Share",
            image: UIImage(systemName: "square.and.arrow.up.fill")) { action in
            // Perform action
          }

          let delete = UIAction(title: "Delete",
            image: UIImage(systemName: "trash.fill"),
            attributes: [.destructive]) { action in
             // Perform action
           }

           return UIContextMenuConfiguration(identifier: nil,
             previewProvider: nil) { _ in
             UIMenu(title: "Actions", children: [favorite, share, delete])
           }
        }
//    func createContextMenu() -> UIMenu {
//        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
//            print("Share")
//        }
//        let copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
//            print("Copy")
//        }
//        let saveToPhotos = UIAction(title: "Add To Photos", image: UIImage(systemName: "photo")) { _ in
//            print("Save to Photos")
//        }
//        return UIMenu(title: "", children: [shareAction, copy, saveToPhotos])
//    }
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
//            return self.createContextMenu()
//        }
//    }
    var kkey :Int?
    
    
    @IBAction func bakward(_ sender: UIButton) {
        if seenStatuskey.count > 1 {
            seenStatuskey.remove(at: seenStatuskey.count-2)
            seenStatuskey.removeLast()
            statuscount -= 1
            detailsCollection.reloadData()
        } else {
            if kkey! > 0 {
                let indexPath = IndexPath(item: kkey!-1, section: 0)
                statuscount = 0
                detailsCollection.scrollToItem(at: indexPath, at: [.left], animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func forward(_ sender: UIButton) {
        
        detailsCollection.reloadData()
        localBool = true
        statuscount += 1
    }
    var localBool = false
    var statuscount = 0
}


extension StatusCollectionVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        print("Yes my Guys \(indexPath.item)")
        return true
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        counter = 0
//        print("Index Path - \(indexPath.item)")
        if kkey == indexPath.item {
            
        } else {
            seenStatuskey.removeAll()
            statuscount = 0
            detailsCollection.reloadData()
        }
        kkey = indexPath.item
        if ifc == 0 {
            print("yes of course")
//            seenStatuskey.removeAll()
            let indexPath = IndexPath(item: identifier!, section: 0)
            kkey = indexPath.item
            detailsCollection.scrollToItem(at: indexPath, at: [.bottom], animated: false)
            ifc = 1
            identifier = nil
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = detailsCollection.dequeueReusableCell(withReuseIdentifier: "StatusDetailsCollectionCell", for: indexPath) as? StatusDetailsCollectionCell
        let frd = statusData[indexPath.item]
        print("frd \(frd)")
        let valll = frd["status"] as? [String:Any]
        print("valll \(valll?.count)")
        let url1 = URL(string: "\(frd["profilepic"] ?? "")")
        progressViews.removeAll()
        stack.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        progressViews  = (0 ..< valll!.count).map { _ in
            let view = UIProgressView()
            view.tintColor = .gray
            view.progress = 0
            return view
        }
        for i in 0...self.progressViews.count-1 {
            if i < self.statuscount {
                self.progressViews[i].setProgress(100, animated: false)
            }
        }
        for progressView in progressViews {
            print("yes")
            progressView.trackTintColor = UIColor.gray
            progressView.progressTintColor = UIColor.blue
//                                progressView.setProgress(50, animated: true)
            stack.addArrangedSubview(progressView)
        }
        print("stack \(progressViews) ---- \(stack)")
        cell?.userImage.kf.setImage(with: url1)
        cell?.userName.text = "\(frd["Name"] ?? "\(frd["Phone number"] ?? "")")"
//        print("statuskey  ... \(frd["statuskey"] ?? "")")
//        print("statusViedeo ... \(valll?["\(frd["statuskey"] ?? "")"] ?? "")")
//        print("cnt  \(cnt)")
//        print("Index Path \(indexPath.row)")
        for i in 0...statuskey.count-1 {
            if valll?["\(statuskey[i])"] != nil {
                if !seenStatuskey.contains("\(statuskey[i])") {
                    seenStatuskey.append("\(statuskey[i])")
                    let photo = valll?["\(statuskey[i])"] as? [String:String]
                    let statuscmt = "\(photo?["statusComment"] ?? "")"
                    print("comment  \(statuscmt)")
                    cell?.statusComment.text = statuscmt
                    url = URL(string: "\(photo?["statusPhoto"] ?? "")")
                    cell?.videoImage.kf.setImage(with: url)
                    break
                }
            }
        }
//        print("seenStatusKey ... \(seenStatuskey)")
        if localBool == true {
            localBool = false
            print("status Count ... \(statuscount)")
            print("vall count ... \(valll!.count)")
            if statuscount >= seenStatuskey.count && statuscount <= valll!.count && kkey!+1 < statusData.count{
                let indexPath = IndexPath(item: kkey!+1, section: 0)
                detailsCollection.scrollToItem(at: indexPath, at: [.right], animated: true)
                statuscount = 0
            } else {
                if statuscount >= valll!.count && kkey!+1 == statusData.count {
                    self.dismiss(animated: true, completion: nil)
                }
            }
           
        }
        if nameText == "You" {
            cell?.dismissBtn.setImage(UIImage(systemName: "ellipsis"), for: .normal)
//            let interaction = UIContextMenuInteraction(delegate: self)
            
//            cell?.dismissBtn.showsMenuAsPrimaryAction = true
//            cell?.dismissBtn.menu = UIMenu(title: "delete", children: [favorite])
//            let interaction = UIContextMenuInteraction(delegate: self)
//            cell?.dismissBtn.addInteraction(interaction)
//            cell?.dismissBtn.isUserInteractionEnabled = true
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cheight = UIScreen.main.bounds.height
        
        let cwidth = UIScreen.main.bounds.width
        return CGSize(width: cwidth, height: cheight)

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
