//
//  NavigationBar.swift
//  qonsultant
//
//  Created by Ahmad Athaullah on 7/20/16.
//  Copyright © 2016 qiscus. All rights reserved.
//

import UIKit

extension UINavigationItem {

    func setTitleWithSubtitle(title:String, subtitle : String){
        
        let titleWidth = UIScreen.main.bounds.size.width - 120
        
        let titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: titleWidth, height: 0))
        titleLabel.backgroundColor = UIColor.clear
//        titleLabel.textColor = ChatViewController().currentNavbarTint
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.tag = 502
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame:CGRect(x: 0, y: 18, width: titleWidth, height: 0))
        subTitleLabel.backgroundColor = UIColor.clear
//        subTitleLabel.textColor = ChatViewController().currentNavbarTint
        subTitleLabel.font = UIFont.systemFont(ofSize: 11)
        subTitleLabel.text = subtitle
        subTitleLabel.tag = 402
        subTitleLabel.textAlignment = .center
        subTitleLabel.sizeToFit()

        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: titleWidth, height: 30))
        
        //if titleLabel.frame.width > titleWidth {
            var adjustmentTitle = titleLabel.frame
            adjustmentTitle.size.width = titleWidth
            titleLabel.frame = adjustmentTitle
        //}
        //if subTitleLabel.frame.width > titleWidth {
            var adjustmentSubtitle = subTitleLabel.frame
            adjustmentSubtitle.size.width = titleWidth
            subTitleLabel.frame = adjustmentSubtitle
        //}
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(subTitleLabel)
        
        self.titleView = titleView
        
    }

}

extension UINavigationController {
    func pushIgnorePreviousVC(to target: UIViewController, except exceptVc: AnyClass) {
        var newVC: [UIViewController ] = []
        for vc in self.viewControllers {
            if vc.isKind(of: exceptVc.self) {
                newVC.append(vc)
            }
        }
        newVC.append(target)
        self.viewControllers = newVC
    }
}

extension UINavigationController {

    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }

}
