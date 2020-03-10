//
//  UIChatListViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore
import PopupDialog

class UIChatListViewController: UIViewController {

    @IBOutlet weak var btStartChat: UIButton!
    @IBOutlet weak var emptyRoomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public var labelProfile = UILabel()
    
    private let presenter : UIChatListPresenter = UIChatListPresenter()
    private let refreshControl = UIRefreshControl()
    
    var rooms : [QChatRoom] {
        get {
            return presenter.rooms
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupUI(){
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
        self.btStartChat.addTarget(self, action: #selector(startChatButtonPressed), for: .touchUpInside)
        self.btStartChat.layer.cornerRadius = 8
        self.title = "Conversations"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UIChatListViewCell.nib, forCellReuseIdentifier: UIChatListViewCell.identifier)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(reloadData(_:)), for: .valueChanged)
        
    
        let buttonProfile = UIButton(type: .custom)
        buttonProfile.frame = CGRect(x: 0, y: 6, width: 30, height: 30)
        buttonProfile.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonProfile.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonProfile.layer.cornerRadius = 15
        buttonProfile.clipsToBounds = true
        
        //load from local
        if let profile = QiscusCoreManager.qiscusCore1.getUserData(){
            buttonProfile.af_setImage(for: .normal, url: profile.avatarUrl)
        }
        
        //load from server
        QiscusCoreManager.qiscusCore1.shared.getUserData(onSuccess: { (profile) in
            buttonProfile.af_setImage(for: .normal, url: profile.avatarUrl)
        }) { (error) in
            //error
        }
        
        buttonProfile.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
        let barButton = UIBarButtonItem(customView: buttonProfile)
        
        let buttonChat = UIButton(type: .custom)
        buttonChat.frame = CGRect(x: 0, y: 6, width: 30, height: 30)
        buttonChat.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonChat.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonChat.layer.cornerRadius = 15
        buttonChat.clipsToBounds = true
        buttonChat.setImage(UIImage(named: "search"), for: .normal)
        buttonChat.addTarget(self, action: #selector(startChatButtonPressed), for: .touchUpInside)
        
        let barButtonChat = UIBarButtonItem(customView: buttonChat)
        
        
        //assign button to navigationbar
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationItem.rightBarButtonItem = barButtonChat
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
        self.presenter.attachView(view: self)
        self.presenter.loadChat()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter.detachView()
    }
    
    @objc private func reloadData(_ sender: Any) {
        self.presenter.reLoadChat()
    }
    
    @objc func profileButtonPressed() {
        self.showPopup()
    }
    
    func showPopup(){
        // Prepare the popup assets
        let title = "WHAT YOU WANT??"
        let message = "You can click 1 menu like Profile, Change APPID2, or cancel"
        let image = UIImage(named: "logo_without_text")

        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)

        // Create buttons
        let buttonOne = CancelButton(title: "CANCEL") {
            //
        }

        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "PROFILE", dismissOnTap: true) {
            let vc = ProfileVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        let buttonThree = DefaultButton(title: "CHANGE APPID2", height: 60, dismissOnTap: true) {
            //check was isLogin or not
            if QiscusCoreManager.qiscusCore2.hasSetupUser(){
               let target = CreateChatViewController()
               self.navigationController?.pushViewController(target, animated: true)
            }else{
                let target = LoginViewController2()
                target.navigationController?.isNavigationBarHidden = false
                self.navigationController?.pushViewController(target, animated: true)
            }
            
        }

        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo, buttonThree])

        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @objc func startChatButtonPressed() {
        let vc = NewConversationVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func chat(withRoom room: QChatRoom){
        let target = UIChatViewController()
        target.room = room
        self.navigationController?.pushViewController(target, animated: true)
    }
}

extension UIChatListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UIChatListViewCell.identifier, for: indexPath) as! UIChatListViewCell
        cell.data = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = self.rooms[indexPath.row]
        self.chat(withRoom: room)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func getIndexpath(byRoom data: QChatRoom) -> IndexPath? {
        // get current index
        for (i,r) in self.rooms.enumerated() {
            if r.id == data.id {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }
}

extension UIChatListViewController : UIChatListView {
    func didUpdate(user: QParticipant, isTyping typing: Bool, in room: QChatRoom) {
        let indexPath = getIndexpath(byRoom: room)
        let isVisible = self.tableView.indexPathsForVisibleRows?.contains{$0 == indexPath}
        if let v = isVisible, let index = indexPath, v == true {
            if let cell: UIChatListViewCell = self.tableView.cellForRow(at: index) as? UIChatListViewCell{
                if typing == true{
                    if(room.type == .group){
                        cell.labelLastMessage.text = "\(user.name) isTyping..."
                    }else{
                         cell.labelLastMessage.text = "isTyping..."
                    }
                }else{
                    cell.labelLastMessage.text = room.lastComment?.message
                }
            }
        }
    }
    
    func updateRooms(data: QChatRoom) {
        self.tableView.reloadData()
    }
    
    func didFinishLoadChat(rooms: [QChatRoom]) {
        if rooms.count == 0 {
            self.emptyRoomView.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.emptyRoomView.isHidden = true
            self.tableView.isHidden = false
            
            // 1st time load data
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            for room in rooms {
                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                    QiscusCoreManager.qiscusCore1.shared.subscribeTyping(roomID: room.id) { (roomTyping) in
                        if let room = QiscusCoreManager.qiscusCore1.database.room.find(id: roomTyping.roomID){
                            self.didUpdate(user: roomTyping.user, isTyping: roomTyping.typing, in: room)
                        }
                    }
                })
            }
        }
       
    }
    
    func startLoading(message: String) {
        //
    }
    
    func finishLoading(message: String) {
        //
    }
    
    func setEmptyData(message: String) {
        //
        self.emptyRoomView.isHidden = false
        self.tableView.isHidden = true
        self.refreshControl.endRefreshing()
    }
}
