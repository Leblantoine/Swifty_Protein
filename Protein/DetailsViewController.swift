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
        

        createAtoms()
        // Do any additional setup after loading the view.
    }
    
    func createAtoms() {
        if let li = ligand {
            for atom in li.atoms {
                print("Add atom \(atom.id)")
                let object: SCNGeometry = SCNSphere(radius: 1)
                object.materials.first?.diffuse.contents = UIColor.blue
                let geometryNode = SCNNode(geometry: object)
                geometryNode.position = SCNVector3(atom.x, atom.y, atom.z)
                scene.rootNode.addChildNode(geometryNode)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showInfos(_ sender: Any) {
        
        if let li = self.ligand {

            // Generate Alert (Modal)
            let alert = UIAlertController(
                title:"Somes informations!",
                 message: li.getInfos(),
                preferredStyle: UIAlertControllerStyle.actionSheet
            )
            
            // Add action Cancel
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
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
