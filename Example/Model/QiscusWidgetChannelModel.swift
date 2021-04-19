//
//  QiscusWidgetChannelModel.swift
//  Example
//
//  Created by Qiscus on 16/04/21.
//  Copyright © 2021 Qiscus. All rights reserved.
//

import Foundation
import SwiftyJSON

public class QiscusWidgetChannelModel : NSObject {
    var id : Int = 0
    var name : String = ""
    var isSelected: Bool = false
    init(json: JSON) {
        self.id             = json["id"].int ?? 0
        self.name           = json["name"].string ?? ""
        self.isSelected     = false
    }
}
