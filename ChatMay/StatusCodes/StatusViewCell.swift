//
//  StatusViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 23/12/22.
//

import UIKit

class StatusViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class StatusPutCell : UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var subLable: UILabel!
}
