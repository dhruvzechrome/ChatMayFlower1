//
//  TableViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 15/10/22.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //    func SetUp(with datauser: Datauser){
    //        userLabel.text = datauser.name
    //
    //
    //    }
    
}


//
//struct Datauser{
//    let name: String
//}
//
//
//var detail:[Datauser] = [
//
//]




