//
//  OtpVerifyCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class OtpVerifyCode: UIViewController {
    private let database = Database.database().reference()
    var verification = ""
    var phone = ""
    @IBOutlet weak var txtOtp: UITextField!
    @IBAction func otpVeri(_ sender: UIButton) {
        print(verification)
        var num = txtOtp.text
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verification,
            verificationCode: num!
        )
        
        
        // OTP Verification Process
        
        Auth.auth().signIn(with: credential) {[self] authResult, error in
            if let error = error {
                let authError = error as NSError
                if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    // The user is a multi-factor user. Second factor challenge is required.
                    let resolver = authError
                        .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                        displayNameString += tmpFactorInfo.displayName ?? ""
                        displayNameString += " "
                    }
                }
                // ...
                let  alert = UIAlertController (title: "OTP Incorrect!!", message: "Enter valid OTP!!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                    
                }))
                self.present(alert, animated: true)
                return
            }
            print("User Singin success")
            
            database.child("Contact List").child(phone).observeSingleEvent(of: .value, with: { snapshot in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if value == nil{
                    print("User is not register" )
                    DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phone,name: "",profileImage : "", location: ""))
                }
                else{
                    print("User is already register" ,value!)
                }
              

              }) { error in
                print(error.localizedDescription)
              }
            
//            observeSingleEvent(of: .value, with: {snapshot in
//                if let founNumber = snapshot.key as? String{
//
//                }  else {
//                    print("snapshot.value   \(snapshot.key)")
//                    print("User is not register" )
//                    DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phone,name: "",profileImage : "", location: ""))
//                    return
//                }
//                print("User is already register" , founNumber)
//            })
            
            
            
            let  alert = UIAlertController (title: "Otp Verified Successfully!!", message: "", preferredStyle: .alert)
            
//            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddUserInformation") as? AddUserInformation
                vc?.phones = self.phone
                self.navigationController?.pushViewController(vc!, animated: true)
//            }))
//            self.present(alert, animated: true)
            
            
            // User is signed in
            // ...
        }
        
        
        ///
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        
        // Do any additional setup after loading the view.
    }
    
}


//DataBaseManager.shared.userExists(with: self.phone, completion: { exists in
//    guard !exists else{
//        // user exists already
//        let  alert = UIAlertController (title: "Otp Verified Successfully!!", message: "", preferredStyle: .alert)
//        
//        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
//        self.navigationController?.pushViewController(vc!, animated: true)}))
//        self.present(alert, animated: true)
//        return
//    }
//    DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phone))
//    let  alert = UIAlertController (title: "Otp Verified Successfully!!", message: "", preferredStyle: .alert)
//    
//                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
//                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
//                        self.navigationController?.pushViewController(vc!, animated: true)
//                    }))
//    self.present(alert, animated: true)
//    // user not exist
//}

////
//        DataBaseManager.shared.userExists(with: phone, completion: { exists in
//            guard !exists else{
//                // user exists already
//
//                return
//            }
//
//            // user not exist
//
//        })
