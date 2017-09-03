//
//  User.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 22/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit

class User {
    
    var email: String?
    var name: String?
    var imageURL: String?
    var uid: String?
    
    init(email: String?, name: String?, imageURL: String?, uid: String?) {
        self.email = email
        self.name = name
        self.imageURL = imageURL
        self.uid = uid
    }
}
