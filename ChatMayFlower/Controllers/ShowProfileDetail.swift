//
//  ShowProfileDetail.swift
//  ChatMayFlower
//
//  Created by iMac on 02/11/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCoreInternal
import FirebaseStorage

class ShowProfileDetail: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    var urlPath = ""                    // url of photos
    var filename = ""                   // path of photo in firebase storage
    var uname = ""                      // user name
    var uphoneno = ""                   // user number
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    var databaseRef: DatabaseReference!
    var phones = ""
    var imag : UIImage?
    var imagearray = [UIImage]()
    
    @IBOutlet weak var logoutoutlet: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.gestureRecognizers?.removeAll()
            phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
            phoneNumber.text = phones
            getData()
        
        
        // Do any additional setup after loading the view.
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
         print("Hello World ")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    func getData(){
        // Create Firebase Storage Reference
        _ = Storage.storage().reference()
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            _ = snapshot.key
            //            print("Key",key)
            guard let _ = snapshot.value as? [String:Any] else {return}
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let _ = snap.key
                    let _ = snap.value!
                    let userMap = snapshot.value! as! [String:String]
                    if userMap["Phone number"] ==  self?.phones {
                        self!.uphoneno = userMap["Phone number"]!
                        
                        if userMap["Name"] != nil {
                            if userMap["Name"] != "" {
                                self!.name.text = userMap["Name"]!
                                self!.uname = userMap["Name"]!
                            }
                            else {
                                self!.uname = "No name available"
                            }
                        }
                        self!.imag = UIImage(named: "placeholder")
                        if userMap["photo url"] != nil  {
                            if userMap["photo url"] != "" {
                                self!.filename = userMap["location"]!
                                self!.urlPath = userMap["photo url"]!
                                let url = URL(string: userMap["photo url"]!)
                                print("URllllllll ----\(String(describing: url))")
                                self!.profileImage.kf.setImage(with: url)
                            }
                            else {
                                self!.profileImage.image = self!.imag
                            }
                        }
                        else {
                            self!.profileImage.image = self!.imag
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func logout(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            navigationController?.pushViewController(vc!, animated: true)
            print("Sign out success")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func editProfile(_ sender: UIBarButtonItem) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileInformation") as? EditProfileInformation
        
        vc?.userImage = imag
        vc?.name = uname
        vc?.number = phones
        vc?.photoUrlPath = urlPath
        vc?.filename = filename
        navigationController?.pushViewController(vc!, animated: true)
    }
}
