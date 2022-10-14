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
        // Do any additional setup after loading the view.
    }


}

