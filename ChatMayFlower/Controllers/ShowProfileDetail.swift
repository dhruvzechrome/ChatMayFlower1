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
    var urlPath = ""
    var filename = ""
    var uname = ""
    var uphoneno = ""
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phoneNumber: UILabel!
    var databaseRef: DatabaseReference!
    var dictArray: [[String:String]] = []
    var array = [String]()
    var phones = ""
    var imag : UIImage?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
        phoneNumber.text = phones
        getData()
    }
    var imagearray = [UIImage]()
    func getData(){
        // Create Firebase Storage Reference
        let storageRef = Storage.storage().reference()
        
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            //            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let cata = snap.key
                    let ques = snap.value!
                    
                    let gif = snapshot.value! as! [String:String]
                    if gif["Phone number"] ==  self?.phones {
                        //                        print("Ppppphhhhh :",gif["Phone number"]!)
                        
//                        self!.phoneNumber.text = gif["Phone number"]!
                        
                        self!.uphoneno = gif["Phone number"]!
                        
                        
                        if gif["Name"] != nil {
                            if gif["Name"] != "" {
                                self!.name.text = gif["Name"]!
                                self!.uname = gif["Name"]!
                            }
                            else {
                                self!.uname = "No name available"
                            }
                        }
//                        print("my image sssssssss \(gif["photo url"]!)")
                        self!.imag = UIImage(named: "placeholder")
                        if gif["photo url"] != nil  {
                            if gif["photo url"] != "" {
                                self!.filename = gif["location"]!
                                self!.urlPath = gif["photo url"]!
                                let url = URL(string: gif["photo url"]!)
                                print("URllllllll ----\(url)")
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
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditProfileInformation") as? EditProfileInformation
        
        vc?.iiimg = imag
        vc?.name = uname
        vc?.number = phones
        vc?.photoUrlPath = urlPath
        vc?.filename = filename
        navigationController?.pushViewController(vc!, animated: true)
    }
}
