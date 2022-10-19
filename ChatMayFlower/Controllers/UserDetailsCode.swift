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
    func getData(){
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            print("Key",key)
            guard let value = snapshot.value as? [String:Any] else {return}
            if let number = value["Phone number"] as? String {
                
                let friend = ChatAppUser(phoneNumber: number)
            
                self?.friends.append(friend)
                
                for i in self!.friends.startIndex...self!.friends.endIndex-1 {
                  print("Integer i",i)
//                    self?.tabelView.reloadData()

                    if self?.friends[i].phoneNumber == FirebaseAuth.Auth.auth().currentUser?.phoneNumber {
                        // Current user
                        print("Diffeent user",self?.friends[i].phoneNumber)
                        self?.reg = i
                        print("number index ",self?.reg)
//                        self?.friends.remove(at: i)
                    }
                }
                if let row = self?.friends.count{
                    let indexPath = IndexPath(row: row-1, section: 0)
                    self?.tabelView.insertRows(at: [indexPath], with: .automatic)
                    print("row",row)
                }
                self?.tabelView.reloadData()
//                self?.friends.remove(at: reg)
                print(self?.friends)
               
                
            }
            
            
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.friends.remove(at: self.reg)
            print(self.friends)
            self.tabelView.reloadData()
            }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validAuth()
        print("current User",FirebaseAuth.Auth.auth().currentUser?.phoneNumber)
       
    }
    
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        cell?.userLabel.text = frd.phoneNumber
//        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = friends[indexPath.row]
        let mun = FirebaseAuth.Auth.auth().currentUser?.phoneNumber
        print("mun is ",mun)
        if (mun == "+916353918909" && frd.phoneNumber == "+917046114310") || (mun == "+917046114310" && frd.phoneNumber == "+916353918909") {
            messageId = "6353918909+917046114310"
            print("my location ",messageId)
        }
        if (mun == "+916353918909" && frd.phoneNumber == "+917984376122") || (mun == "+917984376122" && frd.phoneNumber == "+916353918909"){
            messageId = "6353918909+917984376122"
        }
        if (mun == "+916353918909" && frd.phoneNumber == "+919714479645") || (mun == "+919714479645" && frd.phoneNumber == "+916353918909"){
            messageId = "6353918909+919714479645"
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.fri = friends
        vc?.id = indexPath.row
        mychat()
        vc?.mid = messageId
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
