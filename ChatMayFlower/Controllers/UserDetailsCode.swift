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


class UserDetailsCode: UIViewController {
    @IBOutlet weak var tabelView: UITableView!
    var phones = ""
    var databaseRef: DatabaseReference!
    var reg: Int = 0
    var messageId:String?
    var friends = [ChatAppUser]()
    var dictArray: [[String:String]] = []
    var array = [String]()
    func getData(){
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let cata = snap.key
                    let ques = snap.value!
                    if ques as! String != self!.phones {
                        self!.array.append("\(ques)")
                    }
                    self!.dictArray.append([cata : String(describing: ques)])
                }
                
            }
            self?.tabelView.reloadData()
            print("key of value is ",self!.array)
            print("dictionary is ",self!.dictArray)
            
            
//            if let number = value["Phone number"] as? String {
//
//                let friend = ChatAppUser(phoneNumber: number)
//
//                self?.friends.append(friend)
//
//                for i in self!.friends.startIndex...self!.friends.endIndex-1 {
//                  print("Integer i",i)
////                    self?.tabelView.reloadData()
//
//                    if self?.friends[i].phoneNumber == FirebaseAuth.Auth.auth().currentUser?.phoneNumber {
//                        // Current user
//                        print("Diffeent user",self?.friends[i].phoneNumber)
//                        self?.reg = i
//                        print("number index ",self?.reg)
////                        self?.friends.remove(at: i)
//                    }
//                }
//                if let row = self?.friends.count{
//                    let indexPath = IndexPath(row: row-1, section: 0)
//                    self?.tabelView.insertRows(at: [indexPath], with: .automatic)
//                    print("row",row)
//                }
//                self?.tabelView.reloadData()
////                self?.friends.remove(at: reg)
//                print(self?.friends)
//
//
//            }
            
            
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
        
        tabelView.delegate = self
        tabelView.dataSource = self
        print(friends)
        getData()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validAuth()
        print("current User",phones)
       
    }
    
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
        }
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
    }
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = array[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        cell?.userLabel.text = frd
//        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = array[indexPath.row]
        let mun = FirebaseAuth.Auth.auth().currentUser?.phoneNumber
        print("mun is ",mun!)
        if (mun == "+916353918909" && frd == "+917046114310") || (mun == "+917046114310" && frd == "+916353918909") {
            messageId = "6353918909+917046114310"
        }
        if (mun == "+916353918909" && frd == "+917984376122") || (mun == "+917984376122" && frd == "+916353918909"){
            messageId = "6353918909+917984376122"
        }
        if (mun == "+916353918909" && frd == "+919714479645") || (mun == "+919714479645" && frd == "+916353918909"){
            messageId = "6353918909+919714479645"
        }
        if (mun == "+917046114310" && frd == "+917984376122") || (mun == "+917984376122" && frd == "+917046114310") {
            messageId = "917046114310+917984376122"
        }
        if (mun == "+917046114310" && frd == "+919714479645") || (mun == "+919714479645" && frd == "+917046114310"){
            messageId = "917046114310+919714479645"
        }
        if (mun == "+917984376122" && frd == "+919714479645") || (mun == "+919714479645" && frd == "+917984376122"){
            messageId = "917984376122+919714479645"
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.fri = array
        vc?.id = indexPath.row
        mychat()
        vc?.mid = messageId!
        vc?.phoneid = phones
        navigationController?.pushViewController(vc!, animated: true)
//        friends = [ChatAppUser]()
    }
    
    
    func mychat(){
        
        
//        DataBaseManager.shared.chatExist(with: messageId!, completion: { exists in
//            guard !exists else{
//                // user Exists already
//            }
//            // user not exists
//            DataBaseManager.shared.createNewChat(with: Message(messagid: messageId, chats: ""))
//        })
        
        
        
        
        databaseRef.child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
            if snapshot.exists(){
                print("true rooms exist")
            }else{
                print("false room doesn't exist")
                DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId!, chats: "", sender: "",uii: 0))
            }
        })
        
    }
    
}
