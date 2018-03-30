//
//  Item.swift
//  ListAFaire
//
//  Created by Alexandre KESSLER on 30/03/2018.
//  Copyright © 2018 Alexandre KESSLER. All rights reserved.
//

import Foundation
class Item : Codable{
    
    var name: String
    var checked = false
    
    init(name: String) {
        self.name = name
    }
    
}
