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

    var ligand: Ligand!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    
    var currentModel = "BallStick"
    
    @IBOutlet weak var proteinView: SCNView!
    @IBOutlet weak var atom: UILabel!
    @IBOutlet weak var atomName: UILabel!
    
    @IBAction func playPauseAction(_ sender: UIBarButtonItem) {
        if scene.rootNode.actionKeys.contains("rotate") {
            scene.rootNode.removeAction(forKey: "rotate")
            self.navigationItem.rightBarButtonItems![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.play, target: self, action: #selector(DetailsViewController.playPauseAction(_:)))
        } else {
            let rotateAction = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 20, z: 0, duration: 30))
            scene.rootNode.runAction(rotateAction, forKey: "rotate")
            self.navigationItem.rightBarButtonItems![2] = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.pause, target: self, action: #selector(DetailsViewController.playPauseAction(_:)))

        }
    }

    @IBAction func switched(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            createBallStickModel(withHydrogen: true)
        case 1:
            createBallsModel(withHydrogen: true)
        case 2:
            if currentModel == "BallStick" {
                createBallStickModel(withHydrogen: false)
            } else {
                createBallsModel(withHydrogen: false)
            }
        default:
            break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        proteinView.allowsCameraControl = true
        proteinView.autoenablesDefaultLighting = true
        
        scene = SCNScene()
        proteinView.scene = scene
        proteinView.isPlaying = true
        
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        atom.isHidden = true
        atomName.isHidden = true
        createBallStickModel(withHydrogen: true)
        // Do any additional setup after loading the view.
    }
    
    func createBallsModel(withHydrogen: Bool) {
        clearModel()
        currentModel = "Balls"
        for atom in ligand.atoms {
            if withHydrogen || (!withHydrogen && atom.name != "H") {
                let object: SCNGeometry = SCNSphere(radius: 1)
                object.firstMaterial?.diffuse.contents = atom.getColor()
                let geometryNode = SCNNode(geometry: object)
                geometryNode.position = SCNVector3(atom.x, atom.y, atom.z)
                geometryNode.name = atom.name
                scene.rootNode.addChildNode(geometryNode)
            }
        }
    }
    
    func createBallStickModel(withHydrogen: Bool) {
        clearModel()
        currentModel = "BallStick"
        for atom in ligand.atoms {
            // Create atoms
            if withHydrogen || (!withHydrogen && atom.name != "H") {
                let object: SCNGeometry = SCNSphere(radius: 0.4)
                object.firstMaterial?.diffuse.contents = atom.getColor()
                let geometryNode = SCNNode(geometry: object)
                geometryNode.position = SCNVector3(atom.x, atom.y, atom.z)
                geometryNode.name = atom.name
                scene.rootNode.addChildNode(geometryNode)
                // Create sticks
                
                for connectedAtom in atom.connect {
                    if withHydrogen || (!withHydrogen && connectedAtom.name != "H") {
                        createStick(between: atom, and: connectedAtom)
                    }
                }
            }
        }
    }
    
    func createStick(between firstAtom: Atom, and secondAtom: Atom) {
        let height = distance(between: firstAtom, and: secondAtom)
        let positionFirstAtom = SCNVector3(firstAtom.x, firstAtom.y, firstAtom.z)
        let positionSecondAtom = SCNVector3(secondAtom.x, secondAtom.y, secondAtom.z)
        
        let cylinder = SCNNode()
        cylinder.position = positionFirstAtom
        let target = SCNNode()
        target.position = positionSecondAtom
        scene.rootNode.addChildNode(target)
        
        let geometryObject = SCNCylinder(radius: 0.1, height: CGFloat(height))
        let geometryNode = SCNNode(geometry: geometryObject)
        geometryNode.position.y = height / 2
        
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = -Float.pi/2
        zAlign.addChildNode(geometryNode)
        
        cylinder.addChildNode(zAlign)
        cylinder.constraints = [SCNLookAtConstraint(target: target)]
        scene.rootNode.addChildNode(cylinder)
    }

func distance(between firstAtom: Atom, and secondAtom: Atom) -> Float {
    let xDiff = firstAtom.x - secondAtom.x
    let yDiff = firstAtom.y - secondAtom.y
    let zDiff = firstAtom.z - secondAtom.z
    
    let distance = Float(sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff))
    
    if (distance < 0) {
        return (distance * -1)
    } else {
        return (distance)
    }
}
    
    func clearModel() {
        for node in scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        proteinView.defaultCameraController.stopInertia()
        for node in scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: proteinView)
            if let hitObject = proteinView.hitTest(location, options: nil).first, let name = hitObject.node.name {
                atomName.text = name
                atom.isHidden = false
                atomName.isHidden = false
            }
        }
    }
    
    @IBAction func takeScreenshot(_ sender: Any) {
        let shareController = SharingController()
        if (shareController.takeScreenshot(viewSnap: proteinView, vc: self) == false) {
            print ("Error")
        }
    }

    @IBAction func showInfos(_ sender: Any) {
        
        
        // Generate Alert (Modal)
        let alert = UIAlertController(
            title:"Somes informations!",
            message: ligand.getInfos(),
            preferredStyle: UIAlertControllerStyle.actionSheet
        )
        
        // Add action Cancel
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { alertAction in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
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
