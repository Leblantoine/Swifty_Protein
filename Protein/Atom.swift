//
//  Atom.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/13/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import Foundation

struct Atom {
    var id: String
    var name: String
    
    var x: Float
    var y: Float
    var z: Float
    
    var connect = [Atom]()
    
    init(id: String, name: String, x: Float, y: Float, z: Float) {
        self.id = id
        self.name = name
        self.x = x
        self.y = y
        self.z = z
    }
}
