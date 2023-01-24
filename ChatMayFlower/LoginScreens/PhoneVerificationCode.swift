//
//  PhoneVerificationCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth

class PhoneVerificationCode: UIViewController, UITextFieldDelegate {
    var verificationID: String?
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func sentOtp(_ sender: UIButton) {
        let phoneNumber = txtPhoneNumber.text
        if phoneNumber?.isValidContact != false {
            // Phone authentiacation OTP sent
            Auth.auth().settings?.isAppVerificationDisabledForTesting = false
            PhoneAuthProvider.provider()
                .verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verificationID, error in
                    if let error = error {
                        print("fail otp sent",error)
                        let  alert = UIAlertController (title: "Otp cannot sent!", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in}))
                        self.present(alert, animated: true)
                        return
                    }
                    // Sign in using the verificationID and the code sent to the user
                    // ...
                    print("sign in success ", verificationID!)
                    // Verification id  for OTPverification
                    self.verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtpVerifyCode") as? OtpVerifyCode
                    vc!.verification = verificationID!
                    vc!.phone = phoneNumber!
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
        }
        else {
            let  alert = UIAlertController (title: "Please Enter Valid Number", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in
                
            }))
            present(alert, animated: true)
        }
    }
}

extension String {
    //    var isPhoneNumber: Bool {
    var isValidContact: Bool {
        let phoneNumberRegex =  "^((0091)|(\\+91)|0?)[6789]{1}\\d{9}$";
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        let isValidPhone = phoneTest.evaluate(with: self)
        return isValidPhone
    }
    
    //        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
    //            let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
    //            let result =  phoneTest.evaluate(with: value)
    //            return result
    //    }
}
