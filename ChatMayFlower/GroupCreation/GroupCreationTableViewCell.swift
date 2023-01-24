//
//  GroupCreationTableViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 30/11/22.
//

import UIKit

class GroupCreationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var userTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
