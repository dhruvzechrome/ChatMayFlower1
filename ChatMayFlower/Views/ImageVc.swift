//
//  ImageVc.swift
//  ChatMayFlower
//
//  Created by iMac on 19/11/22.
//

import UIKit
import Kingfisher
class ImageVc: UIViewController {

    @IBOutlet weak var imageShow: UIImageView!
    var str:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = URL(string: str ?? "")
        imageShow.kf.setImage(with: url)
    }

}
