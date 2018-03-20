//
//  Plane.swift
//  ARCube
//
//  Created by mac126 on 2018/3/20.
//  Copyright © 2018年 mac126. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Plane: SCNNode {
    var anthor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    init(withAnthor anthor: ARPlaneAnchor) {
        super.init()
        
        self.anthor = anthor
        planeGeometry = SCNPlane(width: CGFloat(anthor.extent.x), height: CGFloat(anthor.extent.z))
        
        // 网格材质
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "tron_grid")
        material.lightingModel = .physicallyBased
        planeGeometry.materials = [material]
        
        // 平面节点
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.position = SCNVector3(anthor.extent.x, 0, anthor.extent.z)
        
        
        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2.0, 1.0, 0, 0)
        
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
