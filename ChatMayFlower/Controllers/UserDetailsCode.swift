//
//  UserDetailsCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCoreInternal
import FirebaseStorage
import Kingfisher
import MBProgressHUD

class UserDetailsCode: UIViewController {
    var forgroupuser = [String]()
    var msgkey = [String]()
    var msgstatus = false
    var usersNumber = ""
    @IBOutlet weak var tabelView: UITableView!
    var phones = ""
    var databaseRef: DatabaseReference!
    var messageId:String?
    var friends = [ChatAppUser]()
    var keyArray = [String]()
    var usersDetails = [[String:Any]]()
    let storageRef = Storage.storage().reference()
    func getData(){
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            self!.mbProgressHUD(text: "Loading.")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshots {
                    //   let cata = snap.key
                    //   let ques = snap.value!
                    
                    let infoMap = snapshot.value! as! [String:String]
                    
                    if snapshot.key != self!.phones {
                        
                        if !self!.keyArray.contains("\(snapshot.key)") {
                            
                            self!.keyArray.append("\(snapshot.key)")
                            print("Aray of number is \(self!.keyArray)")
                         
                            if infoMap["group name"] != nil {
                                
                                
                            }
                            if infoMap["Name"] != nil {
                                
                                if infoMap["photo url"] != nil {
                                    self!.usersDetails.append(["Name" : infoMap["Name"]! , "Phone number": infoMap["Phone number"]!, "profilepic": infoMap["photo url"]!])
                                    print("usersDetails----------->>>\(self!.usersDetails)")
                                } else {
                                    self!.usersDetails.append(["Name" : infoMap["Name"]! , "Phone number": infoMap["Phone number"]!, "profilepic": ""])
                                    print("usersDetails----------->>>\(self!.usersDetails)")
                                }
                                
                            } else if infoMap["group name"] != nil {
                                self?.forgroupuser.removeAll()
                                let grps = "\(infoMap["group user"]!)"
                                let ffhhf = grps.split(separator: "+")
                                print("=====ffhhf=======\(ffhhf.count)")
                                for i in 0...ffhhf.count-1 {
                                    if self!.phones == "+\(ffhhf[i])" {
                                        print("yes")
                                        self!.usersDetails.append(["group name" : "\(infoMap["group name"]!)" , "Phone number": infoMap["group user"]!, "profilepic": ""])
                                        break
                                    } else {
                                        print("god")
                                    }
                                    
                                }
                               
                            }
                            else {
                                self!.usersDetails.append(["Name" : "" , "Phone number": infoMap["Phone number"]!, "profilepic": ""])
                                print("usersDetails----------->>>\(self!.usersDetails)")
                            }
                            
                        }
                    }
                    
                    
                }
            }
            print("Sbapshot is ", snapshot.value!)
            //            self?.tabelView.reloadData()
        }
    }
    
    
    func getMessageId() {
        databaseRef = Database.database().reference().child("Chats")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            //            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {
                print("No data Found")
                return
            }
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    let cata = key
                    if !(self?.msgkey.contains("\(cata)"))!{
                        self!.msgkey.append("\(cata)")
                    }
                }
            } else {
                print("No data Found")
            }
            print("msg key \(self?.msgkey)")
            self?.tabelView.reloadData()
            self?.hideProgress()
        }
    }
    
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
            print("Sign out success")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mbProgressHUD(text: "Loading..")
        tabelView.delegate = self
        tabelView.dataSource = self
        print(friends)
        getMessageId()
        getData()
        
        //        let refreshControl = UIRefreshControl()
        //        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        //           self.tabelView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender : Any)
    {
        keyArray = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            getData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        validAuth()
        print("current User",phones)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        tabBarController?.tabBar.isHidden = false
        navigationItem.hidesBackButton = true
        tabBarController?.tabBarItem.accessibilityElementIsFocused()
    }
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            navigationController?.pushViewController(vc!, animated: true)
            hideProgress()
        }
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
    }
    
    @IBAction func groupNav(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GroupCreationCode") as? GroupCreationCode
        vc?.usersDetails = usersDetails
        vc?.phones = phones
        navigationController?.present(vc!, animated: true, completion: nil)
        
    }
    
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersDetails[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        cell?.userLabel.text = frd["Phone number"] as? String
        if frd["group name"] == nil {
            
        } else {
            cell?.userLabel.text = frd["group name"] as? String
        }
        print("my image is \(frd["profilepic"]!)")
        
        if frd["profilepic"] as! String == "" {
            cell?.profile.image = UIImage(named: "person")
        } else {
            let url = URL(string: frd["profilepic"]! as! String)
            cell?.profile.kf.setImage(with: url)
        }
        //        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = usersDetails[indexPath.row]
        usersNumber = frd["Phone number"]! as! String
        print("userNumber is \(usersNumber)")
        if msgkey.count > 0 {
            for avl in 0...msgkey.count - 1 {
                print("msgkey at index  \(msgkey[avl])")
                if msgkey[avl] == "\(phones)\(usersNumber)" || msgkey[avl] == "\(usersNumber)\(phones)" || msgkey[avl] == "\(usersNumber)" {
                    messageId = msgkey[avl]
                    // print("True -----------")
                    msgstatus = true
                    break
                }
            }
        }
        mbProgressHUD(text: "Loading..")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.receiverid = usersNumber
        if frd["group name"] == nil {
            
        } else {
            vc?.receiverid = frd["group name"] as! String
            vc?.groupK = "yes"
        }
        mychat()
        vc?.mid = messageId!
        vc?.phoneid = phones
        
        navigationController?.pushViewController(vc!, animated: true)
        hideProgress()
        //        friends = [ChatAppUser]()
    }
    
    
    func mychat() {
        
        if msgstatus == false {
            messageId = "\(phones)\(usersNumber)"
            databaseRef.child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
                if snapshot.exists() {
                    print("true rooms exist")
                } else {
                    print("false room doesn't exist")
                    DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId!, chats: "", sender: "",uii: 0, chatPhotos: ""))
                }
            })
        }
    }
    
}

extension UserDetailsCode {
  func mbProgressHUD(text: String){
    DispatchQueue.main.async {
      let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
      progressHUD.label.text = text
      progressHUD.contentColor = .systemBlue
    }
  }
  func hideProgress(){
    DispatchQueue.main.async {
      MBProgressHUD.hide(for: self.view, animated: false)
    }
  }
}
