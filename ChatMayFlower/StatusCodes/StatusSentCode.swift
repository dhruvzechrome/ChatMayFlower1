//
//  StatusSentCodeViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 26/12/22.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
class StatusSentCode: UIViewController {
    let database = Database.database().reference()
    var currentUserData : [String:String] = [:]
    var currentUser = ""
    var image :UIImage?
    public let percentThresholdDismiss: CGFloat = 0.3
    public var velocityDismiss: CGFloat = 300
    public var axis: NSLayoutConstraint.Axis = .vertical
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
        
        if image != nil {
            imageView.image = image
        }
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func sentStatus(_ sender: UIButton) {
        
        guard image != nil else{
//            if tName.text != "" && tPhoneNumber.text != ""{
//
//
//
//                DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.number,name: tName.text!,profileImage : photoUrlPath, location: filename!))
//                //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
//                //                vc?.phones = self.number
//                self.navigationController?.popViewController(animated: true)
//            }
            return
        }
        
       
        // Create Firebase Storage Reference
        let storageRef = Storage.storage().reference()
        
        
        let imageData = image!.jpegData(compressionQuality: 0.4)
        
        guard imageData != nil else {
            return
        }
        // imagesRef still points to "images"
      
        let filename = "statusimages/\(UUID().uuidString).jpg"
    
        let fileRef = storageRef.child(filename)
        print("\(fileRef)")
        
        // This is equivalent to creating the full reference
        // Upload data
        let _ = fileRef.putData(imageData!, metadata: nil) { [self] metadata, error in
            var urlpth = ""
            // Check error
            if error == nil && metadata != nil {
                if textField.text != "" {
                    
                    
                    fileRef.downloadURL {
                        url, error in
                        if let error = error {
                            // Handle any errors
                            print(error)
                        } else {
                            urlpth = "\(url!)"
                            // Get the download URL for 'Lessons_Lesson1_Class1.mp3'
                            let ref = database.child("Contact List").child("\(currentUser)").child("status").child("\(UUID().uuid.0)")
                    
                            ref.updateChildValues(["statusPhoto":"\(urlpth)", "statusComment" : textField.text!]) { error, _ in
                                guard error == nil else {
                                    print("Failedt Update")
                                    return
                                }
                                print("Update Successfully")
                                self.dismiss(animated: true)
                            }
                            
                            self.navigationController?.popViewController(animated: true)
                        }
                        
                    }
                    //                    print("Urllll ---sdsdfsdf-->",urlpth)
                    
                    //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShowProfileDetail") as? ShowProfileDetail
                    //                    vc?.phones = self.number
                    
                }
            }
            print("Error ====== \(String(describing: error))")
        }
        
        
        
    }
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
