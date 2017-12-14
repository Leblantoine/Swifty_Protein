//
//  DetailsViewController.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/11/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit
import SceneKit

class DetailsViewController: UIViewController {

    var ligand: Ligand?
    @IBOutlet weak var proteinView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    @IBOutlet weak var atom: UILabel!
    @IBOutlet weak var atomName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proteinView.allowsCameraControl = true
        proteinView.autoenablesDefaultLighting = true
        proteinView.backgroundColor = UIColor.white

        
        scene = SCNScene()
        proteinView.scene = scene
        proteinView.isPlaying = true
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(100.0, 500.0, 0.0)
        

        atom.isHidden = true
        atomName.isHidden = true
        createAtoms()
        // Do any additional setup after loading the view.
    }
    
    func createAtoms() {
        if let l = ligand {
            for atom in l.atoms {
                let object: SCNGeometry = SCNSphere(radius: 1)
                object.materials.first?.diffuse.contents = atom.getColor()
                let geometryNode = SCNNode(geometry: object)
                geometryNode.position = SCNVector3(atom.x, atom.y, atom.z)
                geometryNode.name = atom.name
                scene.rootNode.addChildNode(geometryNode)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: proteinView)
            if let hitObject = proteinView.hitTest(location, options: nil).first {
                atomName.text = hitObject.node.name
                atom.isHidden = false
                atomName.isHidden = false
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
