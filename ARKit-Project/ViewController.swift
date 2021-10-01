//
//  ViewController.swift
//  ARKit-Project
//
//  Created by Kellyane Nogueira on 29/09/21.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var session = ARSession()
    var configuration = ARWorldTrackingConfiguration()
    let textures = ["Sorrindo", "Apaixonado", "Irritado"]
    var currentIndex = 0
    var currentTexture = ""
    
    var planes = [ARPlaneAnchor: Plane]()
    var visibleGrid: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        let sceneController = SCNScene()
        sceneView.scene = sceneController
        
        currentTexture = textures[currentIndex]
        
//        let emoji = createEmoji(currentTexture)
//        sceneView.scene.rootNode.addChildNode(emoji)
        //addRotation(emoji: emoji)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints] //ARSCNDebugOptions.showWorldOrigin]
    }

    func setup() {
        sceneView.delegate = self
        sceneView.session = session
        configureLighting()
    }
    
    func addRotation(emoji: SCNNode) {
        let action = SCNAction.rotate(by: 360 * CGFloat((Double.pi)/180), around: SCNVector3(x:0, y:1, z:0), duration: 4)
        let repeatAction = SCNAction.repeatForever(action)
        emoji.runAction(repeatAction)
    }
    
    func createEmoji(texture: String) -> SCNNode {
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: texture)
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "sphere"
       // sphereNode.position = SCNVector3(0, 0, -3)
        
        return sphereNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        if touch.view == self.sceneView {
            
            // MARK: hitTest
//            let viewTouchLocation: CGPoint = touch.location(in: sceneView)
//
//            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
//                return
//            }
//
//            if result.node.name == "sphere" {
//                let node = result.node
//                currentIndex = currentIndex == 0 ? 1 : currentIndex == 1 ? 2 : 0
//                currentTexture = textures[currentIndex]
//                node.geometry?.firstMaterial?.diffuse.contents = currentTexture
//            }

            // MARK: Raycast
            let tapLocation = touch.location(in: self.sceneView)
          guard let nodeResult = sceneView.raycastQuery(from: tapLocation,
                                                          allowing: .existingPlaneGeometry,
                                                          alignment: .horizontal) else {return}
            guard let result = sceneView.session.raycast(nodeResult).first else {
                return
            }

            let newEmoji = createEmoji(texture: textures.randomElement() ?? "Sorrindo")
            newEmoji.transform = SCNMatrix4(result.worldTransform)

            sceneView.scene.rootNode.addChildNode(newEmoji)

        }
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
         DispatchQueue.main.async {
             if let planeAnchor = anchor as? ARPlaneAnchor {
                 self.addPlane(node: node, anchor: planeAnchor)
             }
         }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
            }
        }
    }
    
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        planes[anchor] = plane
        plane.setPlaneVisibility(self.visibleGrid)

        node.addChildNode(plane)
        print("Added plane: \(plane)")
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
    
}
