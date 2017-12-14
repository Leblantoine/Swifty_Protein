//
//  Atom.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/13/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import Foundation
import UIKit

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
    
    func getColor() -> UIColor {
        switch name {
        case "H":
            return UIColor.white
        case "C":
            return UIColor.black
        case "N":
            return UIColor.blue
        case "O":
            return UIColor.red
        case "F", "CI":
            return UIColor.green
        case "BR":
            return UIColor(red:0.60, green:0.13, blue:0.00, alpha:1.0) // Dark red
        case "I":
            return UIColor(red:0.40, green:0.00, blue:0.73, alpha:1.0) // Dark violet
        case "HE", "NE", "AR", "XE", "KR":
            return UIColor.cyan
        case "P":
            return UIColor.orange
        case "S":
            return UIColor.yellow
        case "B":
            return UIColor(red:1.00, green:0.67, blue:0.47, alpha:1.0) // Peach
        case "LI", "NA", "K", "RB", "CS", "FR":
            return UIColor(red:0.47, green:0.00, blue:1.00, alpha:1.0) // Violet
        case "BE", "MG", "CA", "SR", "BA", "RA":
            return UIColor(red:0.00, green:0.47, blue:0.00, alpha:1.0) // Dark green
        case "TI":
            return UIColor.gray
        case "FE":
            return UIColor(red:0.87, green:0.47, blue:0.00, alpha:1.0) // Dark Orange
        default:
            return UIColor(red:0.87, green:0.47, blue:1.00, alpha:1.0) // Pink
        }
        
    }
}
