//
//  ChatTableViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 17/10/22.
//

import UIKit

class ChatTableViewCell: UITableViewCell{
    
}

class SenderImageChatCell : UITableViewCell {
    
    @IBOutlet weak var senderImage: UIImageView!
}

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var photos: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

class ReceiverViewCell: UITableViewCell {
    
    @IBOutlet weak var receiverMessages: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}


class SenderViewCell : UITableViewCell{
    
    @IBOutlet weak var senderMessage: UILabel!
}


