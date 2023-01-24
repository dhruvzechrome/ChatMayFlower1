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
    var statusData = [[String:Any]]()
    var details = [[[String:String]](),[[String:Any]]()]
    var key = [String]()
    var currentUserData : [String:String] = [:]
    var currentAData : [String:Any] = [:]
    var statusImage : UIImage?
    var identifier : Int?
    @IBOutlet weak var subLabel: UILabel!
    
    @IBAction func camera(_ sender: UIButton) {
        print("Image Tapped")
        let vc = storyboard?.instantiateViewController(withIdentifier: "CameraAndLibraryController") as? CameraAndLibraryController
        vc?.modalPresentationStyle = .overFullScreen
//            navigationController?.show(vc!, sender: nil)
        vc?.currentUserData = currentUserData
        vc?.currentUser = currentUser
        navigationController?.present(vc!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Status"
        statusTableView.delegate = self
        statusTableView.dataSource = self
        getContact()
        getData()

    }
    
    func my() {
        if statusImage != nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "StatusSentCode") as? StatusSentCode
            vc?.image = statusImage!
            vc?.currentUser = currentUser
            vc?.currentUserData = currentUserData
            statusImage = nil
            vc?.modalPresentationStyle = .overFullScreen
            navigationController?.present(vc!, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        currentUser = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
        print("--\(statusImage)")
        if statusImage != nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "StatusSentCode") as? StatusSentCode
            vc?.image = statusImage!
            vc?.currentUser = currentUser
            vc?.currentUserData = currentUserData
            statusImage = nil
            vc?.modalPresentationStyle = .fullScreen
            navigationController?.present(vc!, animated: true, completion: nil)
        }
        
        getData()
        print("Current user == \(currentUser)")
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
    var currentUserStatus = [String:Any]()
    var statuskey = [String]()
    var statusDetail = [[String:String]]()
    func getData() {
        // Create Firebase Storage Reference
//        statuskey.removeAll()
//        statusDetail.removeAll()
//        currentUserData.removeAll()
//        currentAData.removeAll()
//        currentUserStatus.removeAll()
//        key.removeAll()
//        statusData.removeAll()
//        details.removeAll()
        _ = Storage.storage().reference()
        
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[self](snapshot) in
            _ = snapshot.key
            print("singh ji",snapshot)
            
            guard let _ = snapshot.value as? [String:Any] else {return}
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot]{
                databaseRef.child("\(snapshot.key)").child("status").observe(.childAdded) { snaps in
                    _ = snaps.value
                    
                    if !statuskey.contains("\(snaps.key)") {
                        print("my status1 \(snaps.key)")
                        statuskey.append("\(snaps.key)")
                        statusDetail.append(snaps.value as! [String:String])
                        print("All user of firebase 121212 \(details) --- \(statuskey)")
                    }
                   
                }
                for snap in snapshots {
                    let _ = snap.key
                    let _ = snap.value!
                    let userMap = snapshot.value! as! [String:Any]
                    
                    if snapshot.key == currentUser {
                        currentUserData["Name"] = "\(userMap["Name"] ?? "")"
                        currentUserData["Phone number"] = "\(userMap["Phone number"] ?? "")"
                        currentUserData["location"] = "\(userMap["location"] ?? "")"
                        currentUserData["profilepic"] = "\(userMap["photo url"] ?? "")"
                        currentUserData["statuskey"] = "\(userMap["statuskey"] ?? "")"
                        currentUserStatus = userMap["status"] as? [String : Any] ?? ["":""]
                        currentUserData["status"] = "\(userMap["status"] ?? "")"
                        
                        currentAData["Name"] = "\(userMap["Name"] ?? "")"
                        currentAData["Phone number"] = "\(userMap["Phone number"] ?? "")"
                        currentAData["location"] = "\(userMap["location"] ?? "")"
                        currentAData["profilepic"] = "\(userMap["photo url"] ?? "")"
                        currentAData["statuskey"] = "\(userMap["statuskey"] ?? "")"
                        currentAData["status"] = userMap["status"] as? [String:Any]
//                            print("my status \(snaps.value)")
                        statusTableView.reloadData()
                    }
                    
                    if !key.contains(snapshot.key) {
                        print("data of all firebase user \(userMap)")
                        if snapshot.key != currentUser {
                            
                            if userMap["status"] != nil {
                                _ = allUser.filter {user in
                                    let frd = user["Phone number"]
                                    if frd == snapshot.key && userMap["status"] != nil{
                                        key.append(snapshot.key)
                                        
//                                        print("Other user status \(snaps.value)")
                                        statusData.append(["Name": "\(user["Name"] ?? "")","Phone number":"\(userMap["Phone number"] ?? "")","status":userMap["status"]! ,"statuskey":"\(userMap["statuskey"] ?? "")","profilepic":"\(userMap["photo url"] ?? "")"])
                                    }
                                    return true
                                }
                            }
                        }
                        
                    }
                    
                }
            }
            details = [[currentUserData], statusData]
            statusTableView.reloadData()
            print("All user of firebase \(details) --- \(statuskey)")
        }
    }
    
}

extension StatusVCViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) { [self] in
            statusTableView.deselectRow(at: indexPath, animated: true)
        }
        if indexPath.section == 0 {
            
            
            if currentUserData["statuskey"] != "" && currentUserStatus["\(currentUserData["statuskey"] ?? "")"] != nil {
//                let frd = currentUserStatus["\(currentUserData["statuskey"] ?? "")"] as! [String:String]
                print("frdddddd = \(currentUserStatus)- - - \(currentUserData)")
                let vc = storyboard?.instantiateViewController(withIdentifier: "StatusCollectionVC") as? StatusCollectionVC
                vc?.statusData = [currentAData]
                vc?.identifier = 0
                vc?.statuskey = statuskey
                vc?.phones = currentUser
                vc?.nameText = "You"
                vc?.modalPresentationStyle = .overFullScreen
                navigationController?.present(vc!, animated: true, completion: nil)
                
            }
            else {
                
                let vc = storyboard?.instantiateViewController(withIdentifier: "CameraAndLibraryController") as? CameraAndLibraryController
                vc?.modalPresentationStyle = .overFullScreen
                //            navigationController?.show(vc!, sender: nil)
                vc?.currentUserData = currentUserData
                vc?.currentUser = currentUser
                navigationController?.present(vc!, animated: true, completion: nil)
                
            }
        } else {
            let frd = details[indexPath.section][indexPath.row]
            let keyS = frd["statuskey"]
            let valll = frd["status"] as? [String:Any]
            let vc = storyboard?.instantiateViewController(withIdentifier: "StatusCollectionVC") as? StatusCollectionVC
            vc?.identifier = indexPath.row
            vc?.statusData = statusData
            vc?.statuskey = statuskey
            vc?.modalPresentationStyle = .overFullScreen
            navigationController?.present(vc!, animated: true, completion: nil)
//            let img = valll?["\(keyS!)"] as? [String:String]
            print("datas    --- --- ---    \(indexPath.row)")
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return section.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("indexPath of section \(indexPath.section) \(indexPath.row)")
        if indexPath.section == 0 {
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "StatusPutCell") as? StatusPutCell
                let url = URL(string: currentUserData["profilepic"] ?? "")
                cell?.profileImage.kf.setImage(with: url)
                    print("Come on yaar \(currentUserStatus)")
            if currentUserData["statuskey"] != ""  && currentUserStatus["\(currentUserData["statuskey"] ?? "")"] != nil{
                        let frd = currentUserStatus["\(currentUserData["statuskey"] ?? "")"] as! [String:String]
                        print("frdddddd = \(currentUserStatus)- - - \(frd)")
                        
                        if frd["statusPhoto"] != nil {
                            let url = URL(string: frd["statusPhoto"]!)
                            cell?.profileImage.kf.setImage(with: url)
                        } else {
                            let url = URL(string: frd["statusVideo"]!)!
                            cell?.profileImage.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
                        }
                        cell?.profileImage.borderWidth = 3
                        cell?.profileImage.borderColor = .blue
                        
                        cell?.subLable.text = "Tap to view status"
                    } else {
                        cell?.profileImage.image = UIImage(systemName: "person.circle.fill")
                    }
                
                
                
            
            
            return cell!
        }else {
            let frd = details[indexPath.section][indexPath.row]
            let keyS = frd["statuskey"]
            let valll = frd["status"] as? [String:Any]
            let img = valll?["\(keyS!)"] as? [String:String]
            print("datas    --- --- ---    \(img)")
            let cell = statusTableView.dequeueReusableCell(withIdentifier: "StatusViewCell") as? StatusViewCell
            cell?.statusImage.image = UIImage(systemName: "circle")
            
            if img?["statusPhoto"] != nil {
                let url = URL(string: img?["statusPhoto"] ?? "")
                print("Photo ")
                cell?.statusImage.kf.setImage(with: url)
            } else {
                let url = URL(string: img?["statusVideo"] ?? "" )
                cell?.statusImage.kf.setImage(with: AVAssetImageDataProvider(assetURL: url!, seconds: 1))
            }
            cell?.userName.text = frd["Name"] as? String
            return cell!
        }
    }
}
