//
//  AppIdentifier.swift
//  My Trolly
//
//  Created by Bhadresh Sorathiya on 24/04/20.
//  Copyright © 2020 wos_Mitesh. All rights reserved.
//

import Foundation

// MARK: All Identifier
struct Identifier {
    
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
