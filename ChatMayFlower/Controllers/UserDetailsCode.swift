//
//  UserDetailsCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class UserDetailsCode: UIViewController {
    
    
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

        DataBaseManager.shared.test()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validAuth()
    }
    
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
        }
    }

//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
}
