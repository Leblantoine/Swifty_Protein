//
//  Ligand.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/10/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import Foundation

struct Ligand {
    var name = "NOT DEFINED"
    var fullname = "NOT DEFINED"
    var type = "NOT DEFINED"
    var formula = "NOT DEFINED"
    var weight = "NOT DEFINED"
    var isDownloaded = false
    
    var atoms = [Atom]()

    init(fromName name: String) {
        self.name = name
    }
    
    func getInfos() -> String {
        
        let n = "\n"
        var infos = n
        
        
        infos = infos + "Name: \(name)" + n + "(\(fullname))" + n
        infos = infos + "Type: \(type)" + n
        infos = infos + "Formula: \(formula)" + n
        infos = infos + "Weight: \(weight)"

        return infos;
    }

    func description() {
        print("Ligand -- name: \(name) (\(fullname)), type: \(type), formula: \(formula), weight: \(weight)")
        for atom in atoms {
            print("\tAtom       -- name: \(atom.name), id: \(atom.id), x: \(atom.x), y: \(atom.y), z: \(atom.z)")
            for atomConnected in atom.connect {
                print("\tConnection -- \(atomConnected.id)")
            }
        }
    }
}
