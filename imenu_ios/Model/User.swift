//
//  User.swift
//  imenu_ios
//
//  Created by Eduardo Antonio Terrero Cabrera on 13/01/2020.
//  Copyright © 2020 Miguel Jaimes. All rights reserved.
//

import UIKit

class User : Codable {
    
    private var name:String?
    private var lastname:String?
    public var email:String?
    public var password:String?
    private var avatar_id:Int?
    
    init(name:String?, lastname:String?, email:String?, password:String?, avatar:Int?) {
        self.name = name
        self.lastname = lastname
        self.email = email
        self.password = password
        self.avatar_id = avatar
    }
    
    init(email:String?, password:String?) {
        self.email = email
        self.password = password
    }
}
