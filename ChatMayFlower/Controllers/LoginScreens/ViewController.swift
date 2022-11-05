//
//  ViewController.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func login(_ sender: UIButton) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
        navigationController?.pushViewController(vc!, animated: true)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tabBarController?.tabBar.isHidden = true

        initializeHideKeyboard()
        // Do any additional setup after loading the view.
    }


}

extension ViewController {
    
    func initializeHideKeyboard(){
        //Declare a Tap Gesture Recognizer which will trigger our dismissMyKeyboard() function
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissMyKeyboard))
        
        //Add this tap gesture recognizer to the parent view
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissMyKeyboard(){
        //endEditing causes the view (or one of its embedded text fields) to resign the first responder status.
        //In short- Dismiss the active keyboard.
        view.endEditing(true)
    }
    
}
