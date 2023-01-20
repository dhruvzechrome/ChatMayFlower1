//
//  UserDetailsCodeForwardViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 10/01/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class UserDetailsCodeForward: UIViewController {
    var allUserOfContact = [[String:String]]()
    var usersDetails = [[String:String]]()
    var msgIdList = [String]()
    @IBOutlet weak var userTable: UITableView!
    var select = 0
    var userKey = [String]()
    var selectedUsers = [[String:String]]()
    var messageId = ""
    var userNumber = ""
    var phones = ""
    var msgstatus = false
    var forwardChat = ""
    var forwardChatVideo = ""
    var forwardChatPhoto = ""
    var forwardChatKey = ""
    var uid : Int?
    var boolforPhoto = false
    @IBOutlet weak var forwardView: UIView!
    @IBOutlet weak var selectedUser: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        userTable.dataSource = self
        userTable.delegate = self
        self.userTable.isEditing = true
        forwardView.isHidden = true
        self.userTable.allowsMultipleSelectionDuringEditing = true
        if usersDetails.count > 0 {
            userTable.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func forwardButton(_ sender: UIButton) {
        print("Yes \(msgIdList)")
        chats()
        let database = Database.database().reference()
        print("ForwardChat - \(forwardChat) | ForwardChatPhoto - \(forwardChatPhoto) | ForwardChatVideo - \(forwardChatVideo) | ForwardChatKey - \(forwardChatKey)")
        if forwardChatPhoto != "" {
            boolforPhoto = false
            print("ForwardChatPhoto - \(forwardChatPhoto)")
            if forwardChat == "" {
                uid! += 1
                database.child("Uid").setValue(uid)
                database.child("Chats").child(messageId).child("chatting").child("\(uid!)").setValue(["\(forwardChatKey)chatPhoto": forwardChatPhoto], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("Failed to write data")
                        
                        return
                    }
                    print("data written seccess")
                    DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                        if let vc = self.presentingViewController as? UITabBarController {
                            if let cvc = vc.viewControllers?.first as? UINavigationController {
                                if let cv = cvc.viewControllers.last as? ChatConversionCode {
                                    self.dismiss(animated: true, completion: nil)
                                    cv.afterForwardPop()
                                }
                            }
                        }
                    }
                })
            } else {
                uid! += 1
                database.child("Uid").setValue(uid)
                database.child("Chats").child(messageId).child("chatting").child("\(uid!)").setValue(["\(forwardChatKey)text": forwardChat,"\(forwardChatKey)chatPhoto": forwardChatPhoto], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        print("Failed to write data")
                        
                        return
                    }
                    print("data written seccess")
                    DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                        if let vc = self.presentingViewController as? UITabBarController {
                            if let cvc = vc.viewControllers?.first as? UINavigationController {
                                if let cv = cvc.viewControllers.last as? ChatConversionCode {
                                    self.dismiss(animated: true, completion: nil)
                                    cv.afterForwardPop()
                                }
                            }
                        }
                    }
                })
            }
        }
       else if forwardChatVideo != "" {
            print("ForwardChatVideo - \(forwardChatVideo)")
            uid! += 1
            database.child("Uid").setValue(uid)
            database.child("Chats").child(messageId).child("chatting").child("\(uid!)").setValue(["\(forwardChatKey)chatVideo": forwardChatVideo], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write data ")
                    return
                }
                print("data written seccess ")
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    if let vc = self.presentingViewController as? UITabBarController {
                        if let cvc = vc.viewControllers?.first as? UINavigationController {
                            if let cv = cvc.viewControllers.last as? ChatConversionCode {
                                self.dismiss(animated: true, completion: nil)
                                cv.afterForwardPop()
                            }
                        }
                    }
                }
            })
        }
        else if forwardChat != "" &&  boolforPhoto == false{
            print("ForwardChat - \(forwardChat)")
            uid! += 1
            database.child("Uid").setValue(uid)
            database.child("Chats").child(messageId).child("chatting").child("\(uid!)").setValue(["\(forwardChatKey)": forwardChat], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write data")
                    
                    return
                }
                print("data written seccess")
                DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
                    
                    if let vc = self.presentingViewController as? UITabBarController {
                        if let cvc = vc.viewControllers?.first as? UINavigationController {
                            if let cv = cvc.viewControllers.last as? ChatConversionCode {
                                self.dismiss(animated: true, completion: nil)
                                cv.afterForwardPop()
                            }
                        }
                    }
                }
            })
        }
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension UserDetailsCodeForward : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersDetails[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserForwardCell", for: indexPath) as? UserForwardCell
        
        cell?.nsme.text = frd["Phone number"]
        _ = allUserOfContact.filter { user in
            //            print("user is \(user)")
            let hib =  user["Phone number"]
            
            if hib == frd["Phone number"] {
                cell?.nsme.text = user["Name"]
            }
            return true
        }
        if frd["group name"] == nil {
            
        } else {
            cell?.nsme.text = frd["group name"]
        }
        print("my image is \(frd["profilepic"]!)")
        
        if frd["profilepic"]! == "" {
            cell?.profile.image = UIImage(named: "person")
        } else {
            print()
            let url = URL(string: frd["profilepic"]! )
            cell?.profile.kf.setImage(with: url)
        }
        //        cell?.SetUp(with: data)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frd = usersDetails[indexPath.row]
        let num = (frd["Phone number"])!
        
        if !userKey.contains(num) {
            userKey.append(num)
            selectedUsers.append(frd)
        }
        if selectedUsers.count > 1 {
            userTable.tableHeaderView = headerview()
            forwardView.isUserInteractionEnabled = false
        } else {
            userTable.tableHeaderView = hideheaderview()
            forwardView.isUserInteractionEnabled = true
        }
        if selectedUsers.count > 0 {
            nameCallValue()
        }
        forwardView.isHidden = false
    }
    
    func nameCallValue(){
        for i in 0...selectedUsers.count-1 {
            let frd = selectedUsers[i]
            userNumber = frd["Phone number"]!
            print("usernun=mber \(userNumber)")
            selectedUser.text = frd["Name"]
            if frd["group name"] == nil {} else {
                selectedUser.text = frd["group name"]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let frd = usersDetails[indexPath.row]
        let num = (frd["Phone number"])!
        
        for i in 0...userKey.count-1 {
            if num == userKey[i] {
                userKey.remove(at: i)
                break
            }
        }
        for i in 0...selectedUsers.count-1 {
            let tds = selectedUsers[i]
            if frd["Phone number"] == tds["Phone number"] {
                selectedUsers.remove(at: i)
                break
            }
        }
        if selectedUsers.count > 1 {
            userTable.tableHeaderView = headerview()
            forwardView.isUserInteractionEnabled = false
        } else {
            userTable.tableHeaderView = hideheaderview()
            forwardView.isUserInteractionEnabled = true
        }
        if selectedUsers.count == 0 {
            forwardView.isHidden = true
        }
        if selectedUsers.count > 0 {
            nameCallValue()
        }
    }
    private func headerview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: userTable.frame.width, height: 30))
        let replyUser = UILabel(frame: CGRect(x: 10, y: 0, width: userTable.frame.width-60, height: 30))
        replyUser.text = "!!!select only one"
        view.backgroundColor = .yellow.withAlphaComponent(0.5)
        view.addSubview(replyUser)
        return view
    }
    private func hideheaderview() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: userTable.frame.width, height: 0))
        return view
    }
    func chats(){
        let frd = selectedUsers[0]
        if frd["uniqueid"] != nil {
            messageId = frd["uniqueid"]!
            print("True ----------- \(messageId)")
        } else {
            for avl in 0...msgIdList.count - 1 {
                print("msgkey at index  \(msgIdList[avl]) - \(phones) - \(userNumber)")
                if msgIdList[avl] == "\(phones)\(userNumber)" || msgIdList[avl] == "\(userNumber)\(phones)" || msgIdList[avl] == "\(userNumber)" {
                    messageId = msgIdList[avl]
                     print("True ----------- \(messageId)")
                    msgstatus = true
                    break
                }
            }
            if msgstatus == false {
                messageId = "\(phones)\(userNumber)"
                
                Database.database().reference().child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
                    if snapshot.exists() {
                        print("true rooms exist")
                    } else {
                        print("false room doesn't exist")
                        DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId, chats: "", sender: "",uii: 0, chatPhotos: ""))
                    }
                })
            }
        }
        
    }
    func mychat() {
        
    }
}

class UserForwardCell : UITableViewCell {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var nsme: UILabel!
    
    
}
