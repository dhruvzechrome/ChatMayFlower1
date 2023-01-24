//
//  ShowProfileViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 15/12/22.
//

import UIKit

class ReceiverProfileViewCell: UITableViewCell {

    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileNumber: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var participant: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

class GroupUserCell : UITableViewCell {
    @IBOutlet weak var groupUserProfile: UIImageView!
    @IBOutlet weak var groupUserName: UILabel!
    @IBOutlet weak var admin: UILabel!
}
