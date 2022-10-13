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
    
    @IBAction func sentOtp(_ sender: UIButton) {
        
        var phoneNumber = txtPhoneNumber.text
        
        if txtPhoneNumber.text?.isValidContact == true {
            
            Auth.auth().settings?.isAppVerificationDisabledForTesting = true
            PhoneAuthProvider.provider()
              .verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { verificationID, error in
                  if let error = error {
                      
                    return
                  }
                  // Sign in using the verificationID and the code sent to the user
                  // ...
                  print("sign in success ", verificationID!)
                  self.verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
                  let vc = self.storyboard?.instantiateViewController(withIdentifier: "OtpVerifyCode") as? OtpVerifyCode
                  vc!.verification = verificationID!
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
