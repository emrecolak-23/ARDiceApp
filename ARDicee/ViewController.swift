//
//  ViewController.swift
//  ARDicee
//
//  Created by Emre Çolak on 24.12.2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self

        sceneView.autoenablesDefaultLighting = true
   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if  ARWorldTrackingConfiguration.isSupported {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
            
            configuration.planeDetection = .horizontal

            
        
        // Run the view's session
        sceneView.session.run(configuration)
            
        } else {
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
       
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = result.first {
                // Create a dice scene

                addDice(atLocation: hitResult)
                print(hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

         diceNode.position = SCNVector3(location.worldTransform.columns.3.x,
                                        location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                        location.worldTransform.columns.3.z)

         diceArray.append(diceNode)
         
         sceneView.scene.rootNode.addChildNode(diceNode)
         
         roll(dice: diceNode)
        }
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)

        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
       
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX)*5, y: 0, z: CGFloat(randomZ)*5, duration: 0.5)
        )
    }
    
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
        
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    //MARK: ARSceneViewDelegate Methods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(with: planeAnchor)
        
        node.addChildNode(planeNode)


       
    }
    
    func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
    
        
                    let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
                    let planeNode = SCNNode()
        
                    planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
                    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
                    let gridMaterial = SCNMaterial()
        
                    gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
                    plane.materials = [gridMaterial]
        
                    planeNode.geometry = plane
        
                    return planeNode
    

    }
   
}
