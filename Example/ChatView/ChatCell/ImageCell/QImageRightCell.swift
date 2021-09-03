//
//  QImageRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 05/09/18.
//

import UIKit
import QiscusCore
import SwiftyJSON
import AlamofireImage
import Alamofire
import SimpleImageViewer
import SDWebImageWebPCoder

class QImageRightCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    var menuConfig = enableMenuConfig()
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbLoading: UILabel!
    var isQiscus : Bool = false
    var message: CommentModel? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu(isQiscus: isQiscus)
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.layer.cornerRadius = 8
        self.ivComment.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QImageRightCell.imageDidTap))
        self.ivComment.addGestureRecognizer(imgTouchEvent)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMassage(_:)),
                                               name: Notification.Name("selectedCell"),
                                               object: nil)
    }
    
    @objc func handleMassage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let commentId = json["commentId"].string ?? "0"
            if let message = self.message {
                if message.id == commentId {
                    self.contentView.backgroundColor = UIColor(red:39/255, green:177/255, blue:153/255, alpha: 0.1)
                }
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu(isQiscus: isQiscus)
    }
    
    override func present(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func update(message: CommentModel) {
        self.bindData(message: message)
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
      ivComment.image = nil // or place holder image
    }
    
    func bindData(message: CommentModel){
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon(message: message)
        self.status(message: message)
        // get image
        self.lbTime.text = self.hour(date: message.date())
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        var placeHolder : UIImage? = nil
        if let messageExtras = message.extras {
            let dataJson = JSON(messageExtras)
            let source = dataJson["source"].string ?? ""
            
            if source.lowercased().contains("ig") == true {
                placeHolder = UIImage(named: "ic_expired_image_ig")
            }
        }
        
        if let caption = caption {
            if caption.contains("This message was sent on previous session") == true {
                
                let messageALL = caption
                let messageALLArr = messageALL.components(separatedBy: "This message was sent on previous session")
                        
                if  messageALLArr.count >= 2 {
                    let message1 = messageALLArr[0] + "&#x2015;&#x2015;&#x2015;<br/><br/><small>"
                    let message1Replace = message1.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    
                    let message2 =  "This message was sent on previous session" + messageALLArr[1]
                    let message2Replace = message2.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    let allMesage = message1Replace + message2Replace
                    
                    let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.white];
                    // create the attributed string
                    let attributedString = NSMutableAttributedString(string: allMesage.htmlToString, attributes: attributedStringColor)
                    
                    if let distance = attributedString.string.distance(of: "This message was sent on previous session") {
                        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: distance , length: attributedString.string.count - distance - 1))
                    }
                    
                    self.tvContent.attributedText = attributedString
                }else{
                    self.tvContent.text = caption
                }
            }else{
                self.tvContent.text = caption
            }
            
        }else{
            self.tvContent.text = ""
        }
        
        self.tvContent.textColor = ColorConfiguration.rightBaloonTextColor
        if let url = payload["url"] as? String {
            if let url = payload["url"] as? String {
                //self.showLoading()
                var fileImage = url
                if fileImage.isEmpty {
                    fileImage = "https://"
                }
                
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: placeHolder, options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
                //self.hideLoading()
            }
        }else{
            if message.message.contains("[sticker]"){
                var fileImage = message.getStickerURL(message: message.message)
                self.showLoading()
                self.ivComment.image = nil
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                
                
                if fileImage.isEmpty == true {
                    fileImage = "https://"
                }
                
                let webPCoder = SDImageWebPCoder.shared
                SDImageCodersManager.shared.addCoder(webPCoder)
                guard let webpURL = URL(string: fileImage)  else {return}
                
                self.ivComment.sd_setImage(with: webpURL) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                        self.hideLoading()
                    }
                   
                }
            }else{
                var fileImage = message.getAttachmentURL(message: message.message)
                
                if fileImage.isEmpty {
                    fileImage = "https://"
                }
                
                //self.showLoading()
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
                
                self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: placeHolder, options: .highPriority) { (uiImage, error, cache, urlPath) in
                    if urlPath != nil && uiImage != nil{
                        self.ivComment.af_setImage(withURL: urlPath!)
                    }
                }
                //self.hideLoading()
            }
        }
        
    }
    
    func hideLoading(){
        self.lbLoading.isHidden = true
        self.ivLoading.isHidden = true
    }
    
    func showLoading(){
        self.lbLoading.isHidden = false
        self.ivLoading.isHidden = false
    }
    
    @objc func imageDidTap() {
        guard let selectedImage = self.ivComment.image else {
            print("Image not found!")
            return
        }
        
        //active this code for detail image
        let configuration = ImageViewerConfiguration { config in
            config.imageView = ivComment
        }
        
        let vc = ImageViewerController(configuration: configuration)

        vc.modalPresentationStyle = .overFullScreen
        self.currentViewController()?.navigationController?.present(vc, animated: false, completion: {
            
        })
        
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.currentViewController()?.navigationController?.present(ac, animated: true, completion: {
            //success
        })
        
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
    
    func setupBalon(message : CommentModel){
        //self.ivBaloonLeft.applyShadow()
        
        guard let payload = message.payload else {
            self.lbNameHeight.constant = 0
            self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
            return
        }
        let caption = payload["caption"] as? String
        
        var dataCaption = ""
        if let caption = caption {
            dataCaption = caption
        }
        self.ivBaloonLeft.image = self.getBallon()
        if message.isMyComment() {
            self.lbNameHeight.constant = 0
            if dataCaption.contains("This message was sent on previous session") == true {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
            } else {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightBaloonColor
            }
        } else {
            self.lbNameHeight.constant = 20
            self.lbName.text = message.username
            if dataCaption.contains("This message was sent on previous session") == true {
                self.ivBaloonLeft.tintColor = ColorConfiguration.rightLeftBaloonGreyColor
                self.lbName.textColor = ColorConfiguration.rightLeftBaloonGreyColor
            }else{
                self.lbName.textColor = ColorConfiguration.otherAgentRightBallonColor
                self.ivBaloonLeft.tintColor = ColorConfiguration.otherAgentRightBallonColor
            }
        }
    }
    
    func status(message: CommentModel){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            lbTime.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time")?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_sending")?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read")?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning")?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted")?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
}
