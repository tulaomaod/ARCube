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
        planeGeometry.height = CGFloat(anthor.extent.z)

        // plane 刚创建时中心点 center 为 0,0,0，node transform 包含了变换参数。
        // plane 更新后变换没变但 center 更新了，所以需要更新 3D 几何体的位置
        position = SCNVector3Make(anthor.center.x, 0, anthor.center.z)
        
        setTextureScale()
        
    }
    
    /// 设置网格纹理
    func setTextureScale() {
        let width = planeGeometry.width
        let height = planeGeometry.height
        
        // 平面的宽度/高度 width/height 更新时，我希望 tron grid material 覆盖整个平面，不断重复纹理。
        // 但如果网格小于 1 个单位，我不希望纹理挤在一起，所以这种情况下通过缩放更新纹理坐标并裁剪纹理
        let material = planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), 1)
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
    
    
}
