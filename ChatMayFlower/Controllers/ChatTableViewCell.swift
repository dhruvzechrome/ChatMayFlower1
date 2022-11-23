//
//  ChatTableViewCell.swift
//  ChatMayFlower
//
//  Created by iMac on 17/10/22.
//

import UIKit
import AVFoundation
import MBProgressHUD
import Kingfisher

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
        
        guard let url = URL(string: videoUrl) else { return }
        senderVideo.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
        senderPlay.image = UIImage(systemName: "play")
//        let  url = URL(string: videoUrl)
//        getThumbnailFromVideoUrl(url: url!) {(thumbnailImage) in
//            self.senderVideo.image = thumbnailImage
//            self.senderPlay.image = UIImage(systemName: "play")
//        }
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
        
        guard let url = URL(string: videoUrl) else { return }
        receiverVideo.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
        receiverPlay.image = UIImage(systemName: "play")
        
//        let  url = URL(string: videoUrl)
//        getThumbnailFromVideoUrl(url: url!) {(thumbnailImage) in
//            self.receiverVideo.image = thumbnailImage
//            self.receiverPlay.image = UIImage(systemName: "play")
//        }
    }
    
//    func getThumbnailFromVideoUrl(url:URL , completion: @escaping((_ image : UIImage?)->Void)){
//        DispatchQueue.global().async {
//            let asset = AVAsset(url: url)
//            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
//            avAssetImageGenerator.appliesPreferredTrackTransform = true
//            let thumbnailTime = CMTimeMake(value: 2, timescale: 2)
//
//            do {
//                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
//                let thumbImage = UIImage(cgImage: cgThumbImage)
//                DispatchQueue.main.async {
//                    completion(thumbImage)
//                }
//
//            }
//            catch{
//
//            }
//        }
//
//    }
}

class SenderReplyViewCell: UITableViewCell {
    
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var senderReply: UILabel!
    @IBOutlet weak var senderMessages: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}

class ReceiverReplyViewCell: UITableViewCell {
    
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var receiverReply: UILabel!
    @IBOutlet weak var receiverMessages: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
}

class SenderReplyImageCell: UITableViewCell {
    
    
    @IBOutlet weak var user: UILabel!
    
    @IBOutlet weak var sendermsg: UILabel!
    
   
    @IBOutlet weak var senderreply: UILabel!
    @IBOutlet weak var imgreplysender: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func confi(videoUrl: String){
        
        let url = URL(string: videoUrl)
        imgreplysender.kf.setImage(with: url)
        
        // - MARK for videos
//        guard let url = URL(string: videoUrl) else {
//            print("error  ")
//            return
//        }
//        imgreplysender.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
    }
    func videocon(videoUrl: String){
        guard let url = URL(string: videoUrl) else { return }
        imgreplysender.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
    }

}
class ReceiverReplyImageCell: UITableViewCell {
    @IBOutlet weak var receivermsg: UILabel!
    @IBOutlet weak var receiverreply: UILabel!
    @IBOutlet weak var imgreplyreceiver: UIImageView!
    
    
    @IBOutlet weak var user: UILabel!
    
    override func awakeFromNib() {
        
        // Initialization code
    }
    
    func confi(videoUrl: String){
        let url = URL(string: videoUrl)
        imgreplyreceiver.kf.setImage(with: url)
        
    }
    
    func videocon(videoUrl: String){
        guard let url = URL(string: videoUrl) else { return }
        imgreplyreceiver.kf.setImage(with: AVAssetImageDataProvider(assetURL: url, seconds: 1))
    }

}

