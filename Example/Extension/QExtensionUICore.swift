//
//  QBallon.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

import Foundation

import QiscusCore
import SwiftyJSON

enum QReplyType:Int{
    case text
    case image
    case video
    case audio
    case document
    case location
    case contact
    case file
    case other
}

extension UIBaseChatCell {
    
    func getBallonRight()->UIImage?{
        var balloonImage:UIImage? = nil
        let edgeInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 28)
        
        balloonImage = AssetsConfiguration.rightBallonLast
        
        return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    }
    
    func getBallonLeft()->UIImage?{
           var balloonImage:UIImage? = nil
           var edgeInset = UIEdgeInsets(top: 13, left: 28, bottom: 13, right: 13)
           balloonImage = AssetsConfiguration.leftBallonLast
        
           return balloonImage?.resizableImage(withCapInsets: edgeInset, resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
       }
    
}
