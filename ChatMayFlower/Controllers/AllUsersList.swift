//
//  AllUsersList.swift
//  ChatMayFlower
//
//  Created by iMac on 05/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class AllUsersList: UIViewController{
    var databaseRef: DatabaseReference!
    var usersNumber = ""
    var usersDetails = [[String:String]]()
    var usersLists = [[String:String]]()   ////  Main list of all contact list
    var allUser = [[String:String]]()
    var phones = ""
    var msgIdList = [String]()
    var msgstatus = false
    var messageId:String?
    @IBOutlet weak var tableViewCell: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewCell.delegate = self
        tableViewCell.dataSource = self
        print("user count = \(usersDetails.count)   all count \(allUser.count)")
        if allUser.count > 0 {
            let UserList = usersDetails
            usersDetails.removeAll()
            for use in 0...UserList.count-1 {
                let frd = UserList[use]
                let splt = frd["Phone number"]?.split(separator: "+")
                if splt?.count == 1 {
                    print("did \(frd)")
                    usersDetails.append(frd)
                }
            }
            
            for use in 0...usersDetails.count-1 {
//                print("User List  --- \(use)")
                let frd = usersDetails[use]
                let filt = allUser.filter { user in
//                    print("user is \(user)")
                    let myNumber =  user["Phone number"]
                    if frd["Phone number"] == myNumber {
//                        print("Hib is +91\(myNumber!)----\(user["Name"])")
                        let str = user["Name"]
                        usersDetails[use] = ["Name": "\(str!)","Phone number": "\(myNumber!)","profilepic": "\(frd["profilepic"]!)"]
                    }
                    return true
                }
            }
            var allUserList = allUser
            var int = 0
            var ik = 0
            for cnt in 0...allUser.count-1 {
                let frd = allUser[cnt]
                for i in 0...usersDetails.count-1 {
                    let data = usersDetails[i]
                    if frd["Phone number"] == data["Phone number"] {
                        if int > ik {
                            print("frd \(frd)---\(cnt)")
                            allUserList.remove(at: cnt-int)
                        } else {
                            print("frd \(frd)---\(cnt)")
                            allUserList.remove(at: cnt)
                        }
                        ik = int
                        int += 1
                        break
                    }
                }
            }
            let list = [["Name" : "Create Group"]]
            usersLists = list + usersDetails + allUserList
            tableViewCell.reloadData()
        }
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension AllUsersList : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersLists[indexPath.row]
        
        let cell = tableViewCell.dequeueReusableCell(withIdentifier: "AllUserTableViewCell", for: indexPath) as? AllUserTableViewCell
        
        cell?.name.text = frd["Name"]
//        let filt = allUser.filter { user in
//            print("user is \(user)")
//            let hib =  user["Phone number"]
////            hib = hib?.replacingOccurrences(of: " ", with: "")
////            hib = hib?.replacingOccurrences(of: "-", with: "")
////            hib = hib?.replacingOccurrences(of: "(", with: "")
////            hib = hib?.replacingOccurrences(of: ")", with: "")
//            print("Hib is +91\(hib!)")
//
//            if hib == frd["Phone number"] || "+91\(hib!)" == frd["Phone number"]{
//                cell?.name.text = user["Name"]
//            }
//            return true
//        }
        if frd["profilepic"] == nil {
            cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
            if indexPath.row == 0 {
                cell?.profileImage.image = UIImage(systemName: "person.2.circle.fill")
            }
        } else {
            let url = URL(string: frd["profilepic"]! )
            cell?.profileImage.kf.setImage(with: url)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableViewCell.deselectRow(at: indexPath, animated: true)
        let frd = usersLists[indexPath.row]
        
        
        if indexPath.row == 0 {
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupCreationCode") as? GroupCreationCode
            vc?.usersList = usersDetails
            vc?.phones = phones
//            self.dismiss(animated: true, completion: nil)
            self.present(vc!, animated: true, completion: nil)
        } else {
            usersNumber = frd["Phone number"]!
            print("userNumber is \(usersNumber)")
            
            if let vc = self.presentingViewController as? UITabBarController {
                if let pv = vc.viewControllers?.first as? UINavigationController {
                    if let pvc = pv.viewControllers.first as? UserDetailsCode {
    //                  pvc.receiverid = usersNumber
                        pvc.newMsg = true
                        pvc.usersNumber = usersNumber
                        pvc.msgIdList = msgIdList
                        pvc.phones = phones
                        dismiss(animated: true)
                    }
                  }
                }
        }
        
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



