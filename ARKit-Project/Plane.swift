//
//  Plane.swift
//  ARKit-Project
//
//  Created by Kellyane Nogueira on 30/09/21.
//
import SceneKit
import ARKit

class Plane: SCNNode {
    var planeAnchor: ARPlaneAnchor
    var planeGeometry: SCNPlane
    var planeNode: SCNNode
    
    init(_ anchor: ARPlaneAnchor) {
        
        self.planeAnchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        
        self.planeGeometry.materials = [material]
        self.planeGeometry.firstMaterial?.transparency = 0.5
        self.planeNode = SCNNode(geometry: planeGeometry)
        self.planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1, 0, 0)
        
        super.init()
        
        self.addChildNode(planeNode)
        
        self.position = SCNVector3(anchor.center.x, -1, anchor.center.z) // 1 below the origin of plane.
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        self.planeAnchor = anchor
        
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        self.position = SCNVector3Make(anchor.center.x, -1, anchor.center.z)
    }
    
    func setPlaneVisibility(_ visible: Bool) {
        self.planeNode.isHidden = !visible
    }
    
}
