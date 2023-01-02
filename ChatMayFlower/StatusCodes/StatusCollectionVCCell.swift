//
//  StatusCollectionVCCell.swift
//  ChatMayFlower
//
//  Created by iMac on 27/12/22.
//

import UIKit

class StatusCollectionVCCell: UICollectionViewCell {
    
    @IBOutlet weak var progressBarC: UIProgressView!
}


class StatusDetailsCollectionCell: UICollectionViewCell {
    @IBOutlet weak var progressCollection: UICollectionView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
}
