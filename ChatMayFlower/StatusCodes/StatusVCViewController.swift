//
//  StatusVCViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 23/12/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Contacts
import Kingfisher
class StatusVCViewController: UIViewController {
    @IBOutlet weak var statusTableView: UITableView!
    var section = ["","Status"]
    var databaseRef: DatabaseReference!
    var currentUser = ""
    var usersDetail = [["orange"],["Banana", "Apple","Mango"]]
    let storeC = CNContactStore()
    var allUser = [[String:String]]()
    var statusData = [[String:String]]()
    var key = [String]()
    var currentUserData : [String:String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusTableView.delegate = self
        statusTableView.dataSource = self
        getContact()
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        currentUser = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
        
//        print("Current user == \(currxxxentUser)")
    }
    func getContact(){
        let authorize = CNContactStore.authorizationStatus(for: .contacts)
        if authorize == .notDetermined {
            storeC.requestAccess(for: .contacts) { (chk, error) in
                if error == nil {
                    
                }
            }
        } else if authorize == .authorized {
            getContactList()
        }
    }
    
    func getContactList() {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: storeC.defaultContainerIdentifier())
        let contct = try! storeC.unifiedContacts(matching: predicate, keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor,CNContactGivenNameKey as CNKeyDescriptor,CNContactMiddleNameKey as CNKeyDescriptor,CNContactFamilyNameKey as CNKeyDescriptor])
        
        for con in contct {
//            print("*Name of contact number ")
            
            for phNO in con.phoneNumbers {
                var hib =  phNO.value.stringValue
                hib = hib.replacingOccurrences(of: " ", with: "")
                hib = hib.replacingOccurrences(of: "-", with: "")
                hib = hib.replacingOccurrences(of: "(", with: "")
                hib = hib.replacingOccurrences(of: ")", with: "")
                if hib.prefix(3) != "+91" {
                    hib = "+91\(hib)"
                }
                allUser.append(["Name" : "\(con.givenName) \(con.middleName) \(con.familyName)","Phone number": hib])
                
            }
        }
        print("List of all user ===========  \(allUser)")
    }
    func getData() {
        // Create Firebase Storage Reference
        _ = Storage.storage().reference()
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[self](snapshot) in
            _ = snapshot.key
            //            print("Key",key)
            guard let _ = snapshot.value as? [String:Any] else {return}
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshots {
                    let _ = snap.key
                    let _ = snap.value!
                    let userMap = snapshot.value! as! [String:String]
                    
                    if snapshot.key == currentUser {
                        currentUserData["Name"] = "\(userMap["Name"] ?? "")"
                        currentUserData["Phone number"] = "\(userMap["Phone number"] ?? "")"
                        currentUserData["location"] = "\(userMap["location"] ?? "")"
                        currentUserData["profilepic"] = "\(userMap["photo url"] ?? "")"
                        statusTableView.reloadData()
                    }
                    
                    if !key.contains(snapshot.key) {
                        print("data of all firebase user \(snapshots)")
                        if snapshot.key != currentUser {
                            key.append(snapshot.key)
                            if userMap["status"] != nil {
                                _ = allUser.filter {user in
                                    let frd = user["Phone number"]
                                    if frd == snapshot.key {
                                        statusData.append(["Name": "\(user["Name"] ?? "")","Phone number":"\(userMap["Phone number"] ?? "")","status":"\(userMap["status"] ?? "")"])
                                    }
                                    return true
                                }
                            }
                        }
                        
                    }
                    
                }
            }
            let iioio = [[currentUserData], statusData]
            print("All user of firebase \(iioio)")
        }
    }
    
}

extension StatusVCViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [self] in
            statusTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersDetail[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = statusData[indexPath.section]
        print("datas    --- --- ---    \(frd)")
        if indexPath.section == 0 {
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "StatusPutCell") as? StatusPutCell
            if currentUserData["profilepic"] != "" {
                let url = URL(string: currentUserData["profilepic"] ?? "")
                cell?.profileImage.kf.setImage(with: url)
            }
            cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
            return cell!
        }else {
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "StatusViewCell") as? StatusViewCell
            cell?.statusImage.image = UIImage(systemName: "circle")
            return cell!
        }
    }
    
    
}
