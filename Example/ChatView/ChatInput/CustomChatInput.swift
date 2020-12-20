//
//  CustomChatInput.swift
//  Example
//
//  Created by Qiscus on 04/09/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import QiscusCore
import SwiftyJSON
import AVFoundation

protocol CustomChatInputDelegate {
    func sendAttachment(button : UIButton)
    func sendMessage(message: CommentModel)
}

class CustomChatInput: UIChatInput {
    
    @IBOutlet weak var viewRecord: UIView!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var heightTextViewCons: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    var chatInputDelegate : CustomChatInputDelegate? = nil
    var defaultInputBarHeight: CGFloat = 34.0
    var customInputBarHeight: CGFloat = 34.0
    var colorName : UIColor = UIColor.black
    
    //rec audio
    var isRecording = false
    var recordingURL:URL?
    var recorder:AVAudioRecorder?
    var recordingSession = AVAudioSession.sharedInstance()
    var recordTimer:Timer?
    var recordDuration:Int = 0
    var processingAudio = false
    
    override func commonInit(nib: UINib) {
        let nib = UINib(nibName: "CustomChatInput", bundle: nil)
        super.commonInit(nib: nib)
        textView.delegate = self
        textView.text = TextConfiguration.sharedInstance.textPlaceholder
        textView.textColor = UIColor.lightGray
        textView.font = ChatConfig.chatFont
        textView.backgroundColor = UIColor.white
        self.textView.layer.cornerRadius = 8
        //self.textView.clipsToBounds = true
        
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        self.sendButton.tintColor = ColorConfiguration.defaultColorTosca
        self.attachButton.tintColor = ColorConfiguration.defaultColorTosca
        self.attachButton.setImage(UIImage(named: "ic_circle_plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.isHidden = true
        self.viewRecord.alpha = 0
    }
    
    @IBAction func clickSend(_ sender: Any) {
        if(self.isRecording == true){
            if !self.processingAudio {
                self.processingAudio = true
                self.finishRecording()
            }
        } else {
            guard let text = self.textView.text else {return}
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && text != TextConfiguration.sharedInstance.textPlaceholder {
                var payload:JSON? = nil
                let comment = CommentModel()
                comment.type = "text"
                comment.message = text
                self.chatInputDelegate?.sendMessage(message: comment)
            }
        }
        self.textView.text = ""
        self.setHeight(50)
        
    }
    
    @IBAction func clickAttachment(_ sender: Any) {
        self.chatInputDelegate?.sendAttachment(button: self.attachButton)
    }
    
    
    func cancelRecord(){
        self.viewRecord.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }) { (_) in
            self.sendButton.isHidden = true
            if self.recordTimer != nil {
                self.recordTimer?.invalidate()
                self.recordTimer = nil
                self.recordDuration = 0
            }
            self.isRecording = false
        }
    }
    
    func onFinishRecording(){
        if(self.isRecording == true){
            if !self.processingAudio {
                self.processingAudio = true
                self.finishRecording()
            }
        }
    }
    
    func finishRecording(){
        self.recorder?.stop()
        self.recorder = nil
         self.viewRecord.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }) { (_) in
            self.sendButton.isHidden = true
            if self.recordTimer != nil {
                self.recordTimer?.invalidate()
                self.recordTimer = nil
                self.recordDuration = 0
            }
            self.isRecording = false
            self.processingAudio = false
        }
        
        if let audioURL = self.recordingURL {
            var fileContent: Data?
            fileContent = try! Data(contentsOf: audioURL)
            let fileName = audioURL.lastPathComponent
            
            QiscusCore.shared.upload(data: fileContent!, filename: fileName, onSuccess: { (file) in
                
                let message = CommentModel()
                message.type = "file_attachment"
                message.payload = [
                    "url"       : file.url.absoluteString,
                    "file_name" : file.name,
                    "size"      : file.size,
                    "caption"   : ""
                ]
                message.message = "Send Audio"
                
                self.chatInputDelegate?.sendMessage(message: message)
            }, onError: { (error) in
                print("Error: \(error)")
            }) { (progress) in
                
            }
            
        }
    }
    
    func startRecording(){
        
        self.viewRecord.alpha = 1
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        let fileName = "audio-\(timeToken).m4a"
        let audioURL = documentsPath.appendingPathComponent(fileName)
        print ("audioURL: \(audioURL)")
        self.recordingURL = audioURL
        let settings:[String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: Float(44100),
            AVNumberOfChannelsKey: Int(2),
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        UIView.animate(withDuration: 0.5, animations: {
            self.inputView?.layoutIfNeeded()
        }, completion: { success in
            
            do {
                self.recorder = nil
                if self.recorder == nil {
                    self.recorder = try AVAudioRecorder(url: audioURL, settings: settings)
                }
                self.recorder?.prepareToRecord()
                self.recorder?.isMeteringEnabled = true
                self.recorder?.record()
                self.sendButton.isEnabled = true
                self.recordDuration = 0
                if self.recordTimer != nil {
                    self.recordTimer?.invalidate()
                    self.recordTimer = nil
                }
                self.recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CustomChatInput.updateTimer), userInfo: nil, repeats: true)
                self.isRecording = true
                let displayLink = CADisplayLink(target: self, selector: #selector(CustomChatInput.updateAudioMeter))
                displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
            } catch {
                print("error recording")
            }
        })
    }
    
    @objc func updateTimer(){
       self.recordDuration += 1
        let minutes = Int(self.recordDuration / 60)
        let seconds = self.recordDuration % 60
        var minutesString = "\(minutes)"
        if minutes < 10 {
            minutesString = "0\(minutes)"
        }
        var secondsString = "\(seconds)"
        if seconds < 10 {
            secondsString = "0\(seconds)"
        }
        //tvTimeRecord.text = "\(minutesString):\(secondsString)"
    }
    @objc func updateAudioMeter(){
        if let audioRecorder = self.recorder{
            audioRecorder.updateMeters()
            let normalizedValue:CGFloat = pow(10.0, CGFloat(audioRecorder.averagePower(forChannel: 0)) / 20)
            if let waveView = self.viewRecord as? QSiriWaveView {
                waveView.update(withLevel: normalizedValue)
            }
        }
    }
    
    func prepareRecording(){
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                if allowed {
                    self.startRecording()
                } else {
                    self.showMicrophoneAccessAlert()
                }
            }
        } catch {
            self.showMicrophoneAccessAlert()
        }
    }
    
    func showMicrophoneAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.microphoneAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: (self.currentViewController()?.navigationController)!, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.currentViewController()?.navigationController?.popViewController(animated: true)
    }
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
}

extension CustomChatInput : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.sendButton.isHidden = false
        self.viewRecord.alpha = 0
        self.hideUIRecord(isHidden: true)
        if(textView.text == TextConfiguration.sharedInstance.textPlaceholder){
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text.isEmpty){
            textView.text = TextConfiguration.sharedInstance.textPlaceholder
            textView.textColor = UIColor.lightGray
            self.sendButton.isHidden = true
            self.viewRecord.alpha = 0
            self.hideUIRecord(isHidden: false)
        }
        self.typing(false, query: textView.text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.typing(true, query: textView.text)
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        if (newSize.height >= 35 && newSize.height <= 170) {
            self.heightTextViewCons.constant = newSize.height
            self.heightView.constant = newSize.height + 10.0
            self.setHeight(self.heightView.constant)
        }
        
        if (newSize.height >= 170) {
            self.textView.isScrollEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == UIPasteboard.general.string){
            self.typing(true, query: text)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
               var maximumLabelSize: CGSize = CGSize(width: self.textView.frame.size.width, height: 170)
                var expectedLabelSize: CGSize = self.textView.sizeThatFits(maximumLabelSize)

                if expectedLabelSize.height >= 170 {
                    self.setHeight(170)
                } else if expectedLabelSize.height <= 48 {
                    self.setHeight(48)
                } else {
                    self.setHeight(expectedLabelSize.height)
                }
            })
            
        }else{
            //User did input by keypad
        }
        return true
    }
}

extension UIChatViewController : CustomChatInputDelegate {
    func uploadCamera() {
        self.view.endEditing(true)
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized
        {
            DispatchQueue.main.async(execute: {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                
                picker.sourceType = UIImagePickerController.SourceType.camera
                self.present(picker, animated: true, completion: nil)
            })
        }else{
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted :Bool) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    if granted {
                        PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                            switch status{
                            case .authorized:
                                let picker = UIImagePickerController()
                                picker.delegate = self
                                picker.allowsEditing = false
                                picker.mediaTypes = [(kUTTypeImage as String),(kUTTypeMovie as String)]
                                
                                picker.sourceType = UIImagePickerController.SourceType.camera
                                self.present(picker, animated: true, completion: nil)
                                break
                            case .denied:
                                self.showPhotoAccessAlert()
                                break
                            default:
                                self.showPhotoAccessAlert()
                                break
                            }
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
                            self.showCameraAccessAlert()
                        })
                    }
                }else{
                    //no camera
                }
                
            })
        }
    }
    
    func uploadGalery() {
        self.view.endEditing(true)
        let photoPermissions = PHPhotoLibrary.authorizationStatus()
        
        if(photoPermissions == PHAuthorizationStatus.authorized){
            self.goToGaleryPicker()
        }else if(photoPermissions == PHAuthorizationStatus.notDetermined){
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    self.goToGaleryPicker()
                    break
                case .denied:
                    self.showPhotoAccessAlert()
                    break
                default:
                    self.showPhotoAccessAlert()
                    break
                }
            })
        }else{
            self.showPhotoAccessAlert()
        }
    }
    
    func uploadFile(){
        if #available(iOS 11.0, *) {
            self.latestNavbarTint = self.currentNavbarTint
            UINavigationBar.appearance().tintColor = UIColor.blue
        }
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: self.UTIs, in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            self.present(picker, animated: true, completion: nil)
        })
    }
    
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.galeryAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    //Alert
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showCameraAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.cameraAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    func sendMessage(message: CommentModel) {
        let postedComment = message

        self.send(message: postedComment, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
    }

    func sendAttachment(button buttonAttachment : UIButton) {
        let optionMenu = UIAlertController()
        let cameraAction = UIAlertAction(title: "Take Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadCamera()
        })
        optionMenu.addAction(cameraAction)


        let galleryAction = UIAlertAction(title: "Image from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadGalery()
        })
        optionMenu.addAction(galleryAction)
        
        let fileAction = UIAlertAction(title: "File / Document", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadFile()
        })
        optionMenu.addAction(fileAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in

        })

        optionMenu.addAction(cancelAction)
        
        
        if let presenter = optionMenu.popoverPresentationController {
            presenter.sourceView = buttonAttachment
            presenter.sourceRect = buttonAttachment.bounds
        }
        
        self.present(optionMenu, animated: true, completion: nil)
    }

    
}

// MARK: - UIDocumentPickerDelegate
extension UIChatViewController: UIDocumentPickerDelegate{
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().tintColor = self.latestNavbarTint
            self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
        self.postReceivedFile(fileUrl: url)
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().tintColor = self.latestNavbarTint
            self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
    }
    
    public func postReceivedFile(fileUrl: URL) {
        let coordinator = NSFileCoordinator()
        coordinator.coordinate(readingItemAt: fileUrl, options: NSFileCoordinator.ReadingOptions.forUploading, error: nil) { (dataURL) in
            do{
                var data:Data = try Data(contentsOf: dataURL, options: NSData.ReadingOptions.mappedIfSafe)
                let mediaSize = Double(data.count) / 1024.0
                var hiddenIconFileAttachment = true
                if mediaSize > self.maxUploadSizeInKB {
                    self.showFileTooBigAlert()
                    return
                }
                
                var fileName = dataURL.lastPathComponent.replacingOccurrences(of: "%20", with: "_")
                fileName = fileName.replacingOccurrences(of: " ", with: "_")
                
                var popupText = TextConfiguration.sharedInstance.confirmationImageUploadText
                var fileType = QiscusFileType.image
                var thumb:UIImage? = nil
                let fileNameArr = (fileName as String).split(separator: ".")
                let ext = String(fileNameArr.last!).lowercased()
                
                let gif = (ext == "gif" || ext == "gif_")
                let video = (ext == "mp4" || ext == "mp4_" || ext == "mov" || ext == "mov_")
                let isImage = (ext == "jpg" || ext == "jpg_" || ext == "tif" || ext == "heic" || ext == "png" || ext == "png_")
                let isPDF = (ext == "pdf" || ext == "pdf_")
                var usePopup = false
                
                if isImage{
                    var i = 0
                    for n in fileNameArr{
                        if i == 0 {
                            fileName = String(n)
                        }else if i == fileNameArr.count - 1 {
                            fileName = "\(fileName).jpg"
                        }else{
                            fileName = "\(fileName).\(String(n))"
                        }
                        i += 1
                    }
                    let image = UIImage(data: data)!
                    let imageSize = image.size
                    var bigPart = CGFloat(0)
                    if(imageSize.width > imageSize.height){
                        bigPart = imageSize.width
                    }else{
                        bigPart = imageSize.height
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    data = image.jpegData(compressionQuality:compressVal)!
                    thumb = UIImage(data: data)
                    usePopup = false
                }else if isPDF{
                    usePopup = true
                    popupText = "Are you sure to send this document?"
                    fileType = QiscusFileType.document
                    if let provider = CGDataProvider(data: data as NSData) {
                        if let pdfDoc = CGPDFDocument(provider) {
                            if let pdfPage:CGPDFPage = pdfDoc.page(at: 1) {
                                var pageRect:CGRect = pdfPage.getBoxRect(.mediaBox)
                                pageRect.size = CGSize(width:pageRect.size.width, height:pageRect.size.height)
                                UIGraphicsBeginImageContext(pageRect.size)
                                if let context:CGContext = UIGraphicsGetCurrentContext(){
                                    context.saveGState()
                                    context.translateBy(x: 0.0, y: pageRect.size.height)
                                    context.scaleBy(x: 1.0, y: -1.0)
                                    context.concatenate(pdfPage.getDrawingTransform(.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true))
                                    context.drawPDFPage(pdfPage)
                                    context.restoreGState()
                                    if let pdfImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                                        thumb = pdfImage
                                    }
                                }
                                UIGraphicsEndImageContext()
                            }
                        }
                    }
                }
                else if gif{
                    let image = UIImage(data: data)!
                    thumb = image
                    let asset = PHAsset.fetchAssets(withALAssetURLs: [dataURL], options: nil)
                    if let phAsset = asset.firstObject {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        option.isNetworkAccessAllowed = true
                        PHImageManager.default().requestImageData(for: phAsset, options: option) {
                            (gifData, dataURI, orientation, info) -> Void in
                            data = gifData!
                        }
                    }
                    popupText = "Are you sure to send this image?"
                    usePopup = true
                }else if video {
                    fileType = .video
                    
                    let assetMedia = AVURLAsset(url: dataURL)
                    let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
                    thumbGenerator.appliesPreferredTrackTransform = true
                    
                    let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 30)
                    let maxSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    thumbGenerator.maximumSize = maxSize
                    
                    do{
                        let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                        thumb = UIImage(cgImage: thumbRef)
                        popupText = "Are you sure to send this video?"
                    }catch{
                        print("error creating thumb image")
                    }
                    usePopup = true
                }else{
                    hiddenIconFileAttachment = false
                    usePopup = true
                    let textFirst = "Are you sure to send this file?"
                    let textMiddle = "\(fileName as String)"
                    let textLast = TextConfiguration.sharedInstance.questionMark
                    popupText = "\(textFirst) \(textMiddle)"
                    fileType = QiscusFileType.file
                    thumb = nil
                }
                
                if usePopup {
                    var message = CommentModel()
                    
                    QPopUpView.showAlert(withTarget: self, image: thumb, message:popupText, isVideoImage: video, hiddenIconFileAttachment: hiddenIconFileAttachment,
                    doneAction: {
                        self.send(message: message, onSuccess: { (comment) in
                        //success
                    }, onError: { (error) in
                        //error
                    })
                    },
                    cancelAction: {
                        //cancel upload
                    })
                    
                    QiscusCore.shared.upload(data: data, filename: fileName, onSuccess: { (file) in
                        message.type = "file_attachment"
                        message.payload = [
                            "url"       : file.url.absoluteString,
                            "file_name" : file.name,
                            "size"      : file.size,
                            "caption"   : ""
                        ]
                        message.message = "Send Attachment"
                        
                        QPopUpView.sharedInstance.hiddenProgress()
                        
                    }, onError: { (error) in
                        //
                    }) { (progress) in
                        print("progress =\(progress)")
                        QPopUpView.sharedInstance.showProgress(progress: progress)
                    }
                }else{
                    let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle: nil)
                    uploader.chatView = self
                    uploader.data = data
                    uploader.fileName = fileName
                    self.navigationController?.pushViewController(uploader, animated: true)
                }
                
            }catch _{
                //finish loading
                //self.dismissLoading()
            }
        }
    }
}

// Image Picker
extension UIChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Fail to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let fileType:String = info[.mediaType] as! String
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        
        if fileType == "public.image"{
            
            var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            var data = image.pngData()
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL{
                imageName = imageURL.lastPathComponent
                
                let imageNameArr = imageName.split(separator: ".")
                let imageExt:String = String(imageNameArr.last!).lowercased()
                
                let gif:Bool = (imageExt == "gif" || imageExt == "gif_")
                let png:Bool = (imageExt == "png" || imageExt == "png_")
                
                if png{
                    data = image.pngData()!
                }else if gif{
                    let asset = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    if let phAsset = asset.firstObject {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        option.isNetworkAccessAllowed = true
                        PHImageManager.default().requestImageData(for: phAsset, options: option) {
                            (gifData, dataURI, orientation, info) -> Void in
                            data = gifData
                        }
                    }
                }else{
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    let asset = result.firstObject
                    imageName = "\((asset?.value(forKey: "filename"))!)"
                    imageName = imageName.replacingOccurrences(of: "HEIC", with: "jpg")
                    let imageSize = image.size
                    var bigPart = CGFloat(0)
                    if(imageSize.width > imageSize.height){
                        bigPart = imageSize.width
                    }else{
                        bigPart = imageSize.height
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    
                    data = image.jpegData(compressionQuality:compressVal)
                }
            }else{
                let imageSize = image.size
                var bigPart = CGFloat(0)
                if(imageSize.width > imageSize.height){
                    bigPart = imageSize.width
                }else{
                    bigPart = imageSize.height
                }
                
                var compressVal = CGFloat(1)
                if(bigPart > 2000){
                    compressVal = 2000 / bigPart
                }
                
                data = image.jpegData(compressionQuality:compressVal)
            }
            
            if data != nil {
                let mediaSize = Double(data!.count) / 1024.0
                if mediaSize > self.maxUploadSizeInKB {
                    picker.dismiss(animated: true, completion: {
                        self.showFileTooBigAlert()
                    })
                    return
                }
                
                dismiss(animated:true, completion: nil)
                
                let uploader = QiscusUploaderVC(nibName: "QiscusUploaderVC", bundle: nil)
                uploader.chatView = self
                uploader.data = data
                uploader.fileName = imageName
                self.navigationController?.pushViewController(uploader, animated: true)
                picker.dismiss(animated: true, completion: {
                    
                })
                
                
            }
            
        }else if fileType == "public.movie" {
            let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            let fileName = mediaURL.lastPathComponent
            
            let mediaData = try? Data(contentsOf: mediaURL)
            let mediaSize = Double(mediaData!.count) / 1024.0
            if mediaSize > self.maxUploadSizeInKB {
                picker.dismiss(animated: true, completion: {
                    self.showFileTooBigAlert()
                })
                return
            }
            //create thumb image
            let assetMedia = AVURLAsset(url: mediaURL)
            let thumbGenerator = AVAssetImageGenerator(asset: assetMedia)
            thumbGenerator.appliesPreferredTrackTransform = true
            
            let thumbTime = CMTimeMakeWithSeconds(0, preferredTimescale: 30)
            let maxSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            thumbGenerator.maximumSize = maxSize
            
            picker.dismiss(animated: true, completion: {
                
            })
            do{
                let thumbRef = try thumbGenerator.copyCGImage(at: thumbTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: thumbRef)
                
                var message = CommentModel()
                
                
                QPopUpView.showAlert(withTarget: self, image: thumbImage, message:"Are you sure to send this video?", isVideoImage: true,
                                     doneAction: {
                                        self.send(message: message, onSuccess: { (comment) in
                                            //success
                                        }, onError: { (error) in
                                            //error
                                        })
                },
                                     cancelAction: {
                                        //cancel upload
                })
                
                QiscusCore.shared.upload(data: mediaData!, filename: fileName, onSuccess: { (file) in
                    message.type = "file_attachment"
                    message.payload = [
                        "url"       : file.url.absoluteString,
                        "file_name" : file.name,
                        "size"      : file.size,
                        "caption"   : ""
                    ]
                    message.message = "Send Attachment"
                    
                    QPopUpView.sharedInstance.hiddenProgress()
                    
                }, onError: { (error) in
                    //
                }) { (progress) in
                    print("progress =\(progress)")
                    QPopUpView.sharedInstance.showProgress(progress: progress)
                }
                
            }catch{
                print("error creating thumb image")
            }
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

