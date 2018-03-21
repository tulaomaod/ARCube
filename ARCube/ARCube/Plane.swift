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
    var planeGeometry: SCNBox!
    
    init(withAnthor anthor: ARPlaneAnchor, isHidden hidden: Bool ) {
        super.init()
        
        self.anthor = anthor
        
        // 使用 SCNBox 替代 SCNPlane 以便场景中的几何体与平面交互。
        // 为了让物理引擎正常工作，需要给平面一些高度以便场景中的几何体与其交互
        let planeHeight:Float = 0.01
        planeGeometry = SCNBox(width: CGFloat(anthor.extent.x), height: CGFloat(planeHeight), length: CGFloat(anthor.extent.z), chamferRadius: 0)
        
        
        // 网格材质
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "tron_grid")
        material.lightingModel = .physicallyBased
        planeGeometry.materials = [material]
        
        // 由于正在使用立方体，但却只需要渲染表面的网格，所以让其他几条边都透明
        let transpatentMaterial = SCNMaterial()
        transpatentMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0)
        if hidden {
            planeGeometry.materials = [transpatentMaterial, transpatentMaterial, transpatentMaterial,
            transpatentMaterial, transpatentMaterial, transpatentMaterial]
        } else {
            planeGeometry.materials = [transpatentMaterial, transpatentMaterial, transpatentMaterial,
            transpatentMaterial, material, transpatentMaterial]
        }

        // 平面节点
        let planeNode = SCNNode(geometry: planeGeometry)
        // 由于平面有一些高度，将其向下移动到实际的表面
        planeNode.position = SCNVector3Make(0, -planeHeight / 2.0, 0)
        
        
        // 设置物理刚体
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
//        // SceneKit 里的平面默认是垂直的，所以需要旋转90度来匹配 ARKit 中的平面
//        planeNode.transform = SCNMatrix4MakeRotation(-.pi / 2.0, 1.0, 0, 0)
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 更新平面
    func update(anthor: ARPlaneAnchor) {
        // 随着用户移动，平面 plane 的 范围 extend 和 位置 location 可能会更新。
        // 需要更新 3D 几何体来匹配 plane 的新参数。
        planeGeometry.width = CGFloat(anthor.extent.x)
        planeGeometry.length = CGFloat(anthor.extent.z)

        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变但 center 更新了，所以需要更新 3D 几何体的位置
        position = SCNVector3Make(anthor.center.x, 0, anthor.center.z)
        
        let node = childNodes.first
        node?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry, options: nil))
        
        setTextureScale()
        
    }
    
    /// 设置网格纹理
    func setTextureScale() {
        let width = planeGeometry.width
        let height = planeGeometry.length
        
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        let material = planeGeometry.materials[4]
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
    }
    
    /// 隐藏
    func hide() {
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: 1.0, alpha: 0)
        planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial,
        transparentMaterial, transparentMaterial, transparentMaterial]
    }
    
    
}
