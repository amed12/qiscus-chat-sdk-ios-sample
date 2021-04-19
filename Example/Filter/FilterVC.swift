//
//  FilterVC.swift
//  Example
//
//  Created by Qiscus on 13/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FilterVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak public var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewChannel: UITableView!
    @IBOutlet weak var tableViewFilter : UITableView!
    @IBOutlet weak var tfFilter: UITextField!
    @IBOutlet weak var tableViewHeightCons: NSLayoutConstraint!
    @IBOutlet weak var btSelectFilter: UIButton!
    @IBOutlet weak var btApply: UIButton!
    //wa
    var resultsWAChannelModel = [WAChannelModel]()
    var channelsModelWA = [ChannelsModel]()
    //line
    var resultsLineChannelModel = [LineChannelModel]()
    var channelsModelLine = [ChannelsModel]()
    //fb
    var resultsFBChannelModel = [FBChannelModel]()
    var channelsModelFB = [ChannelsModel]()
    //custom channel
    var resultsCustomCHChannelModel = [CustomCHChannelModel]()
    var channelsModelCustomCH = [ChannelsModel]()
    
    //QiscusWidget channel
    var resultsQiscusWidgetChannelModel = [QiscusWidgetChannelModel]()
    var channelsModelQiscusWidget = [ChannelsModel]()
    
    //Telegram channel
    var resultsTelegramChannelModel = [TelegramChannelModel]()
    var channelsModelTelegram = [ChannelsModel]()
    
    var selectedTypeWA : String = ""
    var defaults = UserDefaults.standard
    var isWASelected : Bool = false
    var isLineSelected : Bool = false
    var isFBSelected : Bool = false
    var isCustomChannelSelected : Bool = false
    var isQiscusWidgetSelected : Bool = false
    var isTelegramSelected : Bool = false
    
    var isShowWAFilter : Bool = false
    var isShowLineFilter : Bool = false
    var isShowFBFilter : Bool = false
    var isShowCustomChannelFilter : Bool = false
    var isShowQiscusWidgetFilter: Bool = false
    var isShowTelegramFilter : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupData()
        self.setupTableView()
        self.setupUI()
    }
    
    func setupUI(){
        self.title = "Filter"
        let backButton = self.backButton(self, action: #selector(FilterVC.goBack))
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.defaultColorTosca
        
        self.btApply.layer.cornerRadius = self.btApply.frame.size.height / 2
        self.btApply.isEnabled = false
        self.btApply.backgroundColor =  UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_close")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UIColor.white
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 20,height: 20)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 20,height: 20)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 20,height: 20))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func resetButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        
        let resetButton = UIButton(frame:CGRect(x: 0,y: 0,width: 20,height: 20))
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: resetButton)
    }
    
    @IBAction func actionFilterClick(_ sender: Any) {
        if self.btSelectFilter.isSelected == false {
            self.btSelectFilter.isSelected = true
            self.tableViewFilter.isHidden = false
        }else{
            self.btSelectFilter.isSelected = false
            self.tableViewFilter.isHidden = true
        }
        
    }
    
    @objc func resetFilter() {
       //resetFilter
        self.navigationItem.rightBarButtonItems = nil
        defaults.removeObject(forKey: "filter")
        defaults.removeObject(forKey: "filterSelectedTypeWA")
        
       
        self.isWASelected = false
        self.isLineSelected = false
        self.isFBSelected = false
        self.isCustomChannelSelected = false
        self.isQiscusWidgetSelected = false
        self.isTelegramSelected = false
        
        self.checkButtonReset()
        
        //todo reset all UI
        self.resultsWAChannelModel.removeAll()
        self.resultsLineChannelModel.removeAll()
        self.resultsFBChannelModel.removeAll()
        self.resultsCustomCHChannelModel.removeAll()
        self.resultsQiscusWidgetChannelModel.removeAll()
        self.resultsTelegramChannelModel.removeAll()
        
        self.channelsModelWA.removeAll()
        self.channelsModelLine.removeAll()
        self.channelsModelFB.removeAll()
        self.channelsModelCustomCH.removeAll()
        self.channelsModelQiscusWidget.removeAll()
        self.channelsModelTelegram.removeAll()
        self.selectedTypeWA = ""
        
        //resetUIWA
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUIWA"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUILine"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUIFB"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUICustomCH"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUIQiscusWidget"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "resetUITelegram"), object: nil)
        
        self.setupData()
    }
    
    @objc func goBack() {
        if let navController = self.navigationController {
            let newVC = HomeVC()

            var stack = navController.viewControllers
            stack.remove(at: stack.count - 1)       // remove current VC
            stack.insert(newVC, at: stack.count) // add the new one
            navController.setViewControllers(stack, animated: true) // boom!
         }
    }
    
    func setupData(){
        self.tableViewChannel.isHidden = true
        self.loadingIndicator.startAnimating()
        self.loadingIndicator.isHidden = false
        
        guard let token = UserDefaults.standard.getAuthenticationToken() else {
            return
        }
        let header = ["Authorization": token, "Qiscus-App-Id": UserDefaults.standard.getAppID() ?? ""] as [String : String]
        Alamofire.request("\(QiscusHelper.getBaseURL())/api/v2/channels", method: .get, parameters: nil, headers: header as! HTTPHeaders).responseJSON { (response) in
            print("response call \(response)")
            if response.result.value != nil {
                if (response.response?.statusCode)! >= 300 {
                    //failed
                    if response.response?.statusCode == 401 {
                        RefreshToken.getRefreshToken(response: JSON(response.result.value)){ (success) in
                            if success == true {
                                self.setupData()
                            } else {
                                self.loadingIndicator.stopAnimating()
                                self.loadingIndicator.isHidden = true
                                return
                            }
                        }
                    }else{
                        //show error
                        self.loadingIndicator.stopAnimating()
                        self.loadingIndicator.isHidden = true
                        
                        let error = JSON(response.result.value)["errors"].string ?? "Something wrong"
                        
                        let vc = AlertAMFailedUpdate()
                        vc.errorMessage = error
                        vc.modalPresentationStyle = .overFullScreen
                        
                        self.navigationController?.present(vc, animated: false, completion: {
                            
                        })
                    }
                } else {
                    //success
                    let json = JSON(response.result.value)
                  
                    let waChannels = json["data"]["wa_channels"].array
                    let lineChannels = json["data"]["line_channels"].array
                    let fbChannels = json["data"]["fb_channels"].array
                    let chChannels = json["data"]["custom_channels"].array
                    let qiscusWidgetChannels = json["data"]["qiscus_channels"].array
                    let telegramChannels = json["data"]["telegram_channels"].array
                    
                    if waChannels?.count != 0 {
                        self.isShowWAFilter = true
                        for data in waChannels! {
                            var dataWA = WAChannelModel(json: data)

                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataWA.id)") == true{
                                    dataWA.isSelected = true
                                }
                            }
                            self.resultsWAChannelModel.append(dataWA)
                        }

                    }
                    
                    if lineChannels?.count != 0 {
                        self.isShowLineFilter = true
                        for data in lineChannels! {
                            var dataLine = LineChannelModel(json: data)

                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataLine.id)") == true{
                                    dataLine.isSelected = true
                                }
                            }
                            self.resultsLineChannelModel.append(dataLine)
                        }

                    }
                    
                    if fbChannels?.count != 0 {
                        self.isShowFBFilter = true
                        for data in fbChannels! {
                            var dataFB = FBChannelModel(json: data)

                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataFB.id)") == true{
                                    dataFB.isSelected = true
                                }
                            }
                            self.resultsFBChannelModel.append(dataFB)
                        }

                    }
                    
                    if chChannels?.count != 0 {
                        self.isShowCustomChannelFilter  = true
                        for data in chChannels! {
                            var dataCH = CustomCHChannelModel(json: data)
                            
                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataCH.id)") == true{
                                    dataCH.isSelected = true
                                }
                            }
                            self.resultsCustomCHChannelModel.append(dataCH)
                        }
                        
                    }
                    
                    if qiscusWidgetChannels?.count != 0 {
                        self.isShowQiscusWidgetFilter  = true
                        for data in qiscusWidgetChannels! {
                            var dataQW = QiscusWidgetChannelModel(json: data)

                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataQW.id)") == true{
                                    dataQW.isSelected = true
                                }
                            }
                            self.resultsQiscusWidgetChannelModel.append(dataQW)
                        }

                    }
                    
                    if telegramChannels?.count != 0 {
                        self.isShowTelegramFilter  = true
                        for data in telegramChannels! {
                            var dataTelegram = TelegramChannelModel(json: data)
                            
                            if let hasFilter = self.defaults.string(forKey: "filter"){
                                if hasFilter.contains("\(dataTelegram.id)") == true{
                                    dataTelegram.isSelected = true
                                }
                            }
                            self.resultsTelegramChannelModel.append(dataTelegram)
                        }
                        
                    }

                    
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                    
                }
            } else if (response.response != nil && (response.response?.statusCode)! == 401) {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            } else {
                //failed
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
        }
    }
    
    @IBAction func applyAction(_ sender: Any) {
        self.btApply.isEnabled = false
        var array = [[String : Any]]()
        
        
        for waChannel in self.channelsModelWA{
            array.append(waChannel.dictio)
        }
        
        for lineChannel in self.channelsModelLine{
            array.append(lineChannel.dictio)
        }
        
        for fbChannel in self.channelsModelFB{
            array.append(fbChannel.dictio)
        }
        
        for customCHChannel in self.channelsModelCustomCH{
            array.append(customCHChannel.dictio)
        }
        
        for qiscusWidgetChannel in self.channelsModelQiscusWidget{
            array.append(qiscusWidgetChannel.dictio)
        }
        
        for telegramChannel in self.channelsModelTelegram{
            array.append(telegramChannel.dictio)
        }
        
        
        let json = JSON(array)
        let representation = json.rawString()
        
        defaults.setValue(representation, forKey: "filter")
        defaults.setValue(self.selectedTypeWA, forKey: "filterSelectedTypeWA")
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { () -> Void in
            self.goBack()
        }
       
    }
    
    func checkButtonReset(){
        var resetActive = false
        
        if isWASelected == true || isLineSelected == true || isFBSelected == true || isCustomChannelSelected == true || isQiscusWidgetSelected == true || isTelegramSelected == true{
            resetActive = true
        }
        
        if resetActive == true {
            self.btApply.backgroundColor = ColorConfiguration.defaultColorTosca
            self.btApply.isEnabled = true
            let resetButton = self.resetButton(self, action: #selector(FilterVC.resetFilter))
            self.navigationItem.rightBarButtonItems = [resetButton]
        }else{
            if let hasFilter = self.defaults.string(forKey: "filter"){
                self.btApply.backgroundColor = ColorConfiguration.defaultColorTosca
                self.btApply.isEnabled = true
                let resetButton = self.resetButton(self, action: #selector(FilterVC.resetFilter))
                self.navigationItem.rightBarButtonItems = [resetButton]
            }else{
                self.btApply.isEnabled = false
                self.btApply.backgroundColor = UIColor(red: 234/255, green: 234/255, blue: 234/255, alpha: 1)
                self.navigationItem.rightBarButtonItems = nil
            }
            
        }
    }

    //tableView
    
    func setupTableView(){
        //table view
        self.tableViewFilter.dataSource = self
        self.tableViewFilter.delegate = self
        self.tableViewFilter.clipsToBounds = false
        self.tableViewFilter.layer.masksToBounds = false
        self.tableViewFilter.layer.shadowColor = UIColor.lightGray.cgColor
        self.tableViewFilter.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.tableViewFilter.layer.shadowRadius = 5.0
        self.tableViewFilter.layer.shadowOpacity = 0.5
        
        self.tableViewChannel.dataSource = self
        self.tableViewChannel.delegate = self
        
        self.tableViewFilter.register(UINib(nibName: "FilterByChannelCell", bundle: nil), forCellReuseIdentifier: "FilterByChannelCellIdentifire")
        
        self.tableViewChannel.register(UINib(nibName: "FilterByChannelCell", bundle: nil), forCellReuseIdentifier: "FilterByChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "WhatsAppChannelCell", bundle: nil), forCellReuseIdentifier: "WhatsAppChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "LineChannelCell", bundle: nil), forCellReuseIdentifier: "LineChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "FBChannelCell", bundle: nil), forCellReuseIdentifier: "FBChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "CustomCHChannelCell", bundle: nil), forCellReuseIdentifier: "CustomCHChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "QiscusWidgetChannelCell", bundle: nil), forCellReuseIdentifier: "QiscusWidgetChannelCellIdentifire")
        self.tableViewChannel.register(UINib(nibName: "TelegramChannelCell", bundle: nil), forCellReuseIdentifier: "TelegramChannelCellIdentifire")
        
        self.tableViewChannel.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewChannel.separatorStyle = .none
        self.tableViewChannel.tableFooterView = UIView()
        
        self.tableViewFilter.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewFilter.tableFooterView = UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewFilter {
            return 1
        }else{
            return 7
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewFilter {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FilterByChannelCellIdentifire", for: indexPath) as! FilterByChannelCell
            cell.lbTitle.text = "Channel"
            return cell
        }else{
            if indexPath.row == 0 {
                return self.filterByChannelCell(tableView: tableView, indexPath: indexPath)
            }else if indexPath.row == 1 {
                return self.filterWA(tableView: tableView, indexPath: indexPath)
            }else if (indexPath.row == 2){
                return self.filterLine(tableView: tableView, indexPath: indexPath)
            }else if (indexPath.row == 3){
                return self.filterFB(tableView: tableView, indexPath: indexPath)
            }else if (indexPath.row == 4){
                return self.filterCustomChannel(tableView: tableView, indexPath: indexPath)
            }else if (indexPath.row == 5){
                return self.filterQiscusWidget(tableView: tableView, indexPath: indexPath)
            }else if (indexPath.row == 6){
                return self.filterTelegram(tableView: tableView, indexPath: indexPath)
            }
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewFilter {
            
        }else{
            if indexPath.row == 1 {
                if self.isShowWAFilter == false{
                    return 0
                }
            } else if indexPath.row == 2 {
                if self.isShowLineFilter == false{
                    return 0
                }
            } else if indexPath.row == 3 {
                if self.isShowFBFilter == false{
                    return 0
                }
            } else if indexPath.row == 4 {
                if self.isShowCustomChannelFilter == false{
                    return 0
                }
            } else if indexPath.row == 5 {
                if self.isShowQiscusWidgetFilter == false{
                    return 0
                }
            } else if indexPath.row == 6 {
                if self.isShowTelegramFilter == false{
                    return 0
                }
            }
        }
        
 
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewFilter {
            if indexPath.row == 0{
                if let hasFilter = defaults.string(forKey: "filter"){
                    let resetButton = self.resetButton(self, action: #selector(FilterVC.resetFilter))
                    self.navigationItem.rightBarButtonItems = nil
                    self.navigationItem.rightBarButtonItems = [resetButton]
                }
                self.tableViewChannel.reloadData()
                self.tableViewChannel.isHidden = false
                self.tableViewFilter.isHidden = true
            }
        }
    }
    
    func filterByChannelCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterByChannelCellIdentifire", for: indexPath) as! FilterByChannelCell
        return cell
    }
    
    func filterWA(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "WhatsAppChannelCellIdentifire", for: indexPath) as! WhatsAppChannelCell
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsWAChannelModel)
        return cell
    }
    
    func filterLine(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "LineChannelCellIdentifire", for: indexPath) as! LineChannelCell
        cell.tag = 3
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsLineChannelModel)
        if isShowLineFilter == false{
            cell.isHidden = true
        }
        return cell
    }
    
    func filterFB(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "FBChannelCellIdentifire", for: indexPath) as! FBChannelCell
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsFBChannelModel)
        return cell
    }
    
    func filterCustomChannel(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCHChannelCellIdentifire", for: indexPath) as! CustomCHChannelCell
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsCustomCHChannelModel)
        return cell
    }
    
    func filterQiscusWidget(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "QiscusWidgetChannelCellIdentifire", for: indexPath) as! QiscusWidgetChannelCell
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsQiscusWidgetChannelModel)
        return cell
    }
    
    func filterTelegram(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "TelegramChannelCellIdentifire", for: indexPath) as! TelegramChannelCell
        cell.delegate = self
        cell.viewController = self
        cell.setupData(data: self.resultsTelegramChannelModel)
        return cell
    }
    
    
}

extension FilterVC : WhatsAppChannelCellDelegate {
    func updateSelectedTypeWA(type : String){
        self.selectedTypeWA = type
    }
    
    func updateDataWA(isWaSelected: Bool, dataWAChannelModel : [WAChannelModel]?){
        self.isWASelected = isWaSelected
        self.checkButtonReset()

        if let dataWAChannelModel = dataWAChannelModel {
            for data in dataWAChannelModel{
                if data.isSelected == true{
                    let dataWA = ChannelsModel(channelID: data.id, source: "wa")
                    channelsModelWA.append(dataWA)
                }else{
                    channelsModelWA.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelWA.removeAll()
        }
    }
}

extension FilterVC : LineChannelCellDelegate {
    func updateDataLine(isLineSelected: Bool, dataLineChannelModel : [LineChannelModel]?){
        self.isLineSelected = isLineSelected
        self.checkButtonReset()

        if let dataLineChannelModel = dataLineChannelModel {
            for data in dataLineChannelModel{
                if data.isSelected == true{
                    let dataLine = ChannelsModel(channelID: data.id, source: "line")
                    channelsModelLine.append(dataLine)
                }else{
                    channelsModelLine.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelLine.removeAll()
        }
    }
}

extension FilterVC : FBChannelCellDelegate {
    func updateDataFB(isFBSelected: Bool, dataFBChannelModel : [FBChannelModel]?){
        self.isFBSelected = isFBSelected
        self.checkButtonReset()

        if let dataFBChannelModel = dataFBChannelModel {
            for data in dataFBChannelModel{
                if data.isSelected == true{
                    let dataFB = ChannelsModel(channelID: data.id, source: "fb")
                    channelsModelFB.append(dataFB)
                }else{
                    channelsModelFB.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelFB.removeAll()
        }
    }
}

extension FilterVC : CustomCHChannelCellDelegate {
    func updateDataCustomCH(isCustomCHSelected: Bool, dataCustomCHChannelModel : [CustomCHChannelModel]?){
        self.isCustomChannelSelected = isCustomCHSelected
        self.checkButtonReset()

        if let dataCustomCHChannelModel = dataCustomCHChannelModel {
            for data in dataCustomCHChannelModel{
                if data.isSelected == true{
                    let dataCustomCH = ChannelsModel(channelID: data.id, source: "\(data.identifierKey)")
                    channelsModelCustomCH.append(dataCustomCH)
                }else{
                    channelsModelCustomCH.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelCustomCH.removeAll()
        }
    }
}

extension FilterVC : QiscusWidgetChannelCellDelegate {
    func updateDataQiscusWidget(isQiscusWidgetSelected: Bool, dataQiscusWidgetChannelModel : [QiscusWidgetChannelModel]?){
        self.isQiscusWidgetSelected = isQiscusWidgetSelected
        self.checkButtonReset()

        if let dataQiscusWidgetChannelModel = dataQiscusWidgetChannelModel {
            for data in dataQiscusWidgetChannelModel{
                if data.isSelected == true{
                    let dataQiscusWidget = ChannelsModel(channelID: data.id, source: "qiscus")
                    channelsModelQiscusWidget.append(dataQiscusWidget)
                }else{
                    channelsModelQiscusWidget.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelQiscusWidget.removeAll()
        }
    }
}

extension FilterVC : TelegramChannelCellDelegate {
    func updateDataTelegram(isTelegramSelected: Bool, dataTelegramChannelModel : [TelegramChannelModel]?){
        self.isTelegramSelected = isTelegramSelected
        self.checkButtonReset()

        if let dataTelegramChannelModel = dataTelegramChannelModel {
            for data in dataTelegramChannelModel{
                if data.isSelected == true{
                    let dataTelegram = ChannelsModel(channelID: data.id, source: "telegram")
                    channelsModelTelegram.append(dataTelegram)
                }else{
                    channelsModelTelegram.removeAll(where: { $0.channel_id == data.id })
                }
            }
        }else{
            //remove
            channelsModelTelegram.removeAll()
        }
    }
}

public class ChannelsModel : NSObject {
    var channel_id : Int = 0
    var source : String = ""
    var dictio : [String: Any] = [String:Any]()
    
    init(channelID: Int, source: String) {
        self.channel_id  = channelID
        self.source      = source
        self.dictio = ["channel_id": channelID, "source": source]
    }
}