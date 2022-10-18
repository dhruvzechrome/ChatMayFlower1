//
//  OtpVerifyCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
class OtpVerifyCode: UIViewController {
        
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
        
        Auth.auth().signIn(with: credential) { authResult, error in
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
            
            DataBaseManager.shared.insertUser(with: ChatAppUser(phoneNumber: self.phone))
            
            
            let  alert = UIAlertController (title: "Otp Verified Successfully!!", message: "", preferredStyle: .alert)
            
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailsCode") as? UserDetailsCode
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }))
            self.present(alert, animated: true)
            
           
            // User is signed in
            // ...
        }
   
        
        ///
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
