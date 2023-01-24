//
//  GroupViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 21/12/22.
//

import UIKit

class GroupViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
