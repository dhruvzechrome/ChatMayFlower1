//
//  CameraAndLibraryController.swift
//  ChatMayFlower
//
//  Created by iMac on 26/12/22.
//

import UIKit
import AVFoundation
import SwiftUI

class CameraAndLibraryController: UIViewController {
    var currentUser = ""
    //Capture session
    var session : AVCaptureSession?
    
    //Photo Output
    let output = AVCapturePhotoOutput()
    var currentUserData : [String:String] = [:]
    //Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    private let sutterButton :UIButton = {
       let button =  UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        button.layer.cornerRadius = 50
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        return button
    }()
    private let pickImage :UIButton = {
       let button =  UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setImage(UIImage(systemName: "photo.fill"), for: .normal)
        button.backgroundColor = UIColor.systemGray4
        button.layer.cornerRadius = 25
        button.tintColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        return button
    }()
    private let cancelButton :UIButton = {
       let button1 =  UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        button1.setTitle("X", for: .normal)
        button1.setImage(UIImage(systemName: "xmark"), for: .normal)
        button1.tintColor = .white
//        button1.layer.cornerRadius = 0
//        button1.layer.borderWidth = 3
//        button1.layer.borderColor = UIColor.white.cgColor
        return button1
    }()
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        pickImage.center = CGPoint(x: 50, y: view.frame.size.height-100)
        cancelButton.center = CGPoint(x: 30, y: 50)
        sutterButton.center = CGPoint(x: view.frame.size.width/2 , y: view.frame.size.height-100)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(sutterButton)
        view.addSubview(cancelButton)
        view.addSubview(pickImage)
        checkCameraPermissions()
        cancelButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        sutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
//        pickimage.addTarget(self, action: #selector(imagepicker), for: .touchUpInside)
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrag(_:))))
        // Do any additional setup after loading the view.
    }
    public let percentThresholdDismiss: CGFloat = 0.3
        public var velocityDismiss: CGFloat = 300
        public var axis: NSLayoutConstraint.Axis = .vertical
//    public var backgroundDismissColor: UIColor = .clear {
//            didSet {
//                navigationController?.view.backgroundColor = backgroundDismissColor
//            }
//        }
    @objc fileprivate func onDrag(_ sender: UIPanGestureRecognizer) {

            let translation = sender.translation(in: view)

            // Movement indication index
            let movementOnAxis: CGFloat

            // Move view to new position
            switch axis {
            case .vertical:
                let newY = min(max(view.frame.minY + translation.y, 0), view.frame.maxY)
                movementOnAxis = newY / view.bounds.height
                view.frame.origin.y = newY

            case .horizontal:
                let newX = min(max(view.frame.minX + translation.x, 0), view.frame.maxX)
                movementOnAxis = newX / view.bounds.width
                view.frame.origin.x = newX
            @unknown default:
                fatalError()
            }

            let positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            let positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            let progress = CGFloat(positiveMovementOnAxisPercent)
        navigationController?.view.backgroundColor = .clear

            switch sender.state {
            case .ended where sender.velocity(in: view).y >= velocityDismiss || progress > percentThresholdDismiss:
                // After animate, user made the conditions to leave
                UIView.animate(withDuration: 0.2, animations: {
                    switch self.axis {
                    case .vertical:
                        self.view.frame.origin.y = self.view.bounds.height

                    case .horizontal:
                        self.view.frame.origin.x = self.view.bounds.width
                    @unknown default:
                        fatalError()
                    }
                    self.navigationController?.view.backgroundColor = .clear

                }, completion: { finish in
                    self.dismiss(animated: true) //Perform dismiss
                })
            case .ended:
                // Revert animation
                UIView.animate(withDuration: 0.2, animations: {
                    switch self.axis {
                    case .vertical:
                        self.view.frame.origin.y = 0

                    case .horizontal:
                        self.view.frame.origin.x = 0
                    @unknown default:
                        fatalError()
                    }
                })
            default:
                break
            }
            sender.setTranslation(.zero, in: view)
        }
    @objc private func dismissScreen() {
        self.dismiss(animated: true, completion: nil)
    }
   
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                guard granted else {
                    return
                }
                DispatchQueue.main.async {
                    self.setUpCamera()
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpCamera() {
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                self.session = session
            }
            catch {
                    print(error)
            }
        }
    }
    @objc private func didTapTakePhoto() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
    }
}

extension CameraAndLibraryController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        
        session?.stopRunning()
        let vc = storyboard?.instantiateViewController(withIdentifier: "") as? StatusSentCode
        vc?.image = image!
        vc?.modalPresentationStyle = .fullScreen
        navigationController?.present(vc!, animated: true, completion: nil)
        
//        let imageView = UIImageView(image: image)
//        imageView.isUserInteractionEnabled = true
//        imageView.contentMode = .scaleAspectFill
//        imageView.frame = view.bounds
//        view.addSubview(imageView)
        
    }
}
