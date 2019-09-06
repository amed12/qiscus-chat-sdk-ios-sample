//
//  UIBottomPopupVC.swift
//  Example
//
//  Created by Qiscus on 06/09/19.
//  Copyright © 2019 Qiscus. All rights reserved.
//

import UIKit
import BottomPopup
import Alamofire
import SwiftyJSON

class UIBottomPopupVC: BottomPopupViewController {
    var width : CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblUnserverOrGetCustomer: UILabel!
    
    @IBOutlet weak var viewBorder: UIView!
    
    @IBOutlet weak var btGetCustomer: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let width = width {
            self.view.frame.size.width = width
        }
        self.setupUI()
    }
    
    func setupUI(){
        self.viewBorder.layer.cornerRadius = 4
        self.btGetCustomer.layer.cornerRadius = self.btGetCustomer.frame.height / 2
        self.btGetCustomer.layer.shadowColor = UIColor(red: 0.35, green: 0.44, blue: 0.25, alpha: 0.25).cgColor
        self.btGetCustomer.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.btGetCustomer.layer.shadowOpacity = 1.0
        self.btGetCustomer.layer.shadowRadius = 4
        
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                
                self.lblUnserverOrGetCustomer.text = "Get Customer"
                self.lblDescription.text = "There is 0 customers is not served by an agent. It can be taken by an Agent one by one"
                self.getCSApi(roleAdmin: false)
                self.btGetCustomer.isHidden = false
            }else{
                self.lblUnserverOrGetCustomer.text = "Unserved Customer"
                self.lblDescription.text = "Unserved customer is the number of customers who have not been served by an agent"
                self.getCSApi(roleAdmin: true)
                self.btGetCustomer.isHidden = true
            }
        }
    }
    
    func getCSApi(roleAdmin : Bool = true){
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token] as [String : String]
        
        Alamofire.request("https://qismo.qiscus.com/api/v1/admin/service/get_unresolved_count", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    if roleAdmin{
                         self.lblCount.text = "0 Person"
                    }else{
                         self.lblCount.text = "0 Customer"
                    }
                  
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    let count = payload["data"]["total_unresolved"].int ?? 0
                    
                    if roleAdmin{
                        self.lblCount.text = "\(count) Person"
                    }else{
                        self.lblCount.text = "\(count) Customer"
                        
                        let main_string = "There is \(count) customers is not served by an agent. It can be taken by an Agent one by one"
                        let string_to_color = "\(count) customers"
                        
                        let range = (main_string as NSString).range(of: string_to_color)
                        
                        let attribute = NSMutableAttributedString.init(string: main_string)
                        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 35/255, green: 176/255, blue: 152/255, alpha: 1) , range: range)
                        self.lblDescription.attributedText = attribute
                    }
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                if roleAdmin{
                    self.lblCount.text = "0 Person"
                }else{
                    self.lblCount.text = "0 Customer"
                }
            } else {
                //failed
                if roleAdmin{
                    self.lblCount.text = "0 Person"
                }else{
                    self.lblCount.text = "0 Customer"
                }
            }
        }
    }
    
    @IBAction func getCustomer(_ sender: Any) {
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        
        let header = ["Authorization": token] as [String : String]
        Alamofire.request("https://qismo.qiscus.com/api/v1/agent/service/takeover_unresolved_room", method: .post, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    let payload = JSON(response.result.value)
                    let errors = payload["errors"].string ?? "Failed Get Customer"
                    self.showAlert(errors)
                } else {
                    //success
                    let payload = JSON(response.result.value)
                    print("check payload2 =\(payload)")
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "reloadListRoom"), object: nil)
                    self.showAlert("Success Get Customer")
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.showAlert("Failed Get Customer")
            } else {
                //failed
                self.showAlert("Failed Get Customer")
            }
        }
    }
    
    func showAlert(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert -> Void in
            
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // Bottom popup attribute methods
    // You can override the desired method to change appearance
    
    override func getPopupHeight() -> CGFloat {
        if let userType = UserDefaults.standard.getUserType(){
            if userType == 2 {
                return 220
            }else{
                return 180
            }
        }else{
            return 180
        }
    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return topCornerRadius ?? CGFloat(10)
    }
    
    override func getPopupPresentDuration() -> Double {
        return presentDuration ?? 1.0
    }
    
    override func getPopupDismissDuration() -> Double {
        return dismissDuration ?? 1.0
    }
    
    override func shouldPopupDismissInteractivelty() -> Bool {
        return shouldDismissInteractivelty ?? true
    }
}
