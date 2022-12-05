//
//  GroupCreationCode.swift
//  ChatMayFlower
//
//  Created by iMac on 30/11/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher


class GroupCreationCode: UIViewController {
    var usersDetails = [[String:Any]]()
    var phones = ""
    var databaseRef = Database.database().reference()
    var groupUser = [String]()
    var groupName = ""
    var uid = ""
    
    @IBOutlet weak var grouptxtField: UITextField!
    @IBOutlet weak var userTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTable.delegate = self
        userTable.dataSource = self
        self.userTable.isEditing = true
        self.userTable.allowsMultipleSelectionDuringEditing = true
        if usersDetails.count > 0 {
            userTable.reloadData()
        }
    }
    
    @IBAction func createGrpButton(_ sender: UIButton) {
        
        mychat()
        let name = grouptxtField.text
        if grouptxtField.text  != "" && groupName != "" {
            databaseRef.child("Contact List").child("\(name!)").setValue(["group name": "\(name!)","group user":"\(phones)\(groupName)","photo url":"","location" : ""], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write data")
                    return
                }
                print("data written seccess")
            })
            databaseRef.child("Chats").child("\(phones)\(groupName)").child("chatting").child("0").setValue(["\(phones)": ""], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("Failed to write data")
                    
                    return
                }
                self.dismiss(animated: true)
                print("data written seccess")
            })
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension GroupCreationCode : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = usersDetails[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCreationTableViewCell", for: indexPath) as? GroupCreationTableViewCell
        cell?.userTitle.text = frd["Phone number"] as? String
        print("my image is \(frd["profilepic"]!)")
        
        if frd["profilepic"] as! String == "" {
            cell?.userProfile.image = UIImage(named: "person")
        } else {
            let url = URL(string: frd["profilepic"]! as! String)
            cell?.userProfile.kf.setImage(with: url)
        }
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let frd = usersDetails[indexPath.row]
        let num = (frd["Phone number"] as? String)!
        if !groupUser.contains(num) {
            groupUser.append(num)
        }
        
        print("\(groupUser)")
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let frd = usersDetails[indexPath.row]
        let num = (frd["Phone number"] as? String)!
        print("\(groupUser)")
        for i in 0...groupUser.count-1 {
            if num == groupUser[i] {
                groupUser.remove(at: i)
                break
            }
        }
    }
    
    func mychat() {
        groupName = ""
        if groupUser.count > 0 {
            for i in 0...groupUser.count-1 {
                groupName = "\(groupName)\(groupUser[i])"
                print(groupName)
            }
            
        }
    }
}
