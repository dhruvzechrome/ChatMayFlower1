//
//  ChatTableViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 17/10/22.
//

import UIKit
import AVFoundation
import MBProgressHUD

class ChatTableViewCell: UITableViewCell {
    
}
class SenderViewCell : UITableViewCell {
    
    @IBOutlet weak var senderMessage: UILabel!
}
class SenderImageChatCell : UITableViewCell {
    
    @IBOutlet weak var senderImageComment: UILabel!
    @IBOutlet weak var senderImage: UIImageView!
}
class SenderVideoCell : UITableViewCell {
    @IBOutlet weak var senderVideo: UIImageView!
    
    @IBOutlet weak var senderPlay: UIImageView!
    
    func confi(videoUrl: String){
        
        let  url = URL(string: videoUrl)
        getThumbnailFromVideoUrl(url: url!) {(thumbnailImage) in
            self.senderVideo.image = thumbnailImage
            self.senderPlay.image = UIImage(systemName: "play")
        }
    }
    
    func getThumbnailFromVideoUrl(url:URL , completion: @escaping((_ image : UIImage?)->Void)){
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 2, timescale: 2)
                
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
                
            }
            catch{
                
            }
        }
        
    }
}

class ImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var receiverComentImage: UILabel!
    
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


class ReceiverVideoCell : UITableViewCell {
    
    @IBOutlet weak var receiverVideo: UIImageView!
    
    @IBOutlet weak var receiverPlay: UIImageView!
    func confi(videoUrl: String){
        
        let  url = URL(string: videoUrl)
        getThumbnailFromVideoUrl(url: url!) {(thumbnailImage) in
            self.receiverVideo.image = thumbnailImage
            self.receiverPlay.image = UIImage(systemName: "play")
        }
    }
    
    func getThumbnailFromVideoUrl(url:URL , completion: @escaping((_ image : UIImage?)->Void)){
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumbnailTime = CMTimeMake(value: 2, timescale: 2)
                
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbImage)
                }
                
            }
            catch{
                
            }
        }
        
    }
}



