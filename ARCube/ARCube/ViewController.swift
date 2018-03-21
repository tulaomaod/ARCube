//
//  ViewController.swift
//  ARCube
//
//  Created by mac126 on 2018/3/20.
//  Copyright © 2018年 mac126. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

/// 碰撞类别
struct CollisonCategory {
    let rawValue: Int
    static let bottom = CollisonCategory(rawValue: 1<<0)    // 0
    static let cube = CollisonCategory(rawValue: 1<<1)      // 2
    
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // UUID 表示UUID字符串，可用于唯一标识类型，接口和其他项目。
    /// 字典，存储场景中当前渲染的所有平面
    var planes = [UUID : Plane]()
    
    /// 包含场景中渲染的小方格
    var boxes = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    /// 设置scene
    func setupScene() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(0, 0, -0.5)
        scene.rootNode.addChildNode(boxNode)
        
        // Set the scene to the view
        sceneView.scene = scene
        // 是否自动点亮没有光源的场景，默认为no
        sceneView.autoenablesDefaultLighting = true
        
        // 显示debug信息，arkit中世界原点和arkit检测到的特征点
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    }
    
    
    /// 设置会话
    func setupSession() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // 检测水平面
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }

    /// 设置手势
    func setupRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTapFrom(recognizer: UITapGestureRecognizer) {
        // 获取屏幕空间坐标并传递给 ARSCNView 实例的 hitTest 方法
        let tapPoint = recognizer.location(in: sceneView)
        let result = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        
        // 如果射线与某个平面几何体相交，就会返回该平面，以离摄像头的距离升序排序
        // 如果命中多次，用距离最近的平面
        if let hitResult = result.first  {
            insertGeometry(hitResult)
        }
    }
    
    /// 插入几何体
    func insertGeometry(_ hitResult: ARHitTestResult) {
        // 现在先插入简单的小方块，后面会让它变得更好玩，有更好的纹理和阴影
        let dimmision: CGFloat = 0.1
        let cube = SCNBox(width: dimmision, height: dimmision, length: dimmision, chamferRadius: 0)
        let node = SCNNode(geometry: cube)
        
        // physicsBody 会让 SceneKit 用物理引擎控制该几何体
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: cube, options: nil))
        // kg为单位指定物体质量，静态默认为0，动态为1
        node.physicsBody?.mass = 2
        node.physicsBody?.categoryBitMask = CollisonCategory.cube.rawValue
        
        // 把几何体插在用户点击的点再稍高一点的位置，以便使用物理引擎来掉落到平面上
        let insertYOffset: Float = 0.5
        node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + insertYOffset, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(node)
        boxes.append(node)
    }

    // MARK: - ARSCNViewDelegate
    
    /**
     实现此方法来为给定 anchor 提供自定义 node。
     
     @discussion 此 node 会被自动添加到 scene graph 中。
     如果没有实现此方法，则会自动创建 node。
     如果返回 nil，则会忽略此 anchor。
     @param renderer 将会用于渲染 scene 的 renderer。
     @param anchor 新添加的 anchor。
     @return 将会映射到 anchor 的 node 或 nil。
     */
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
     
 */
    
    /// 有新的node映射到给定的anchor时调用
    ///
    /// - Parameters:
    ///   - renderer: 用于渲染scene的renderer
    ///   - node: 映射到anthor的node
    ///   - anchor: 新添加的anthor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else {
            return
        }
        print(anchor)
        let plane = Plane(withAnthor: anchor, isHidden: false)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    /**
     使用给定 anchor 的数据更新 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 更新后的 node。
     @param anchor 更新后的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let plane = planes[anchor.identifier] else { return }
        
        // anchor 更新后也需要更新 3D 几何体。例如平面检测的高度和宽度可能会改变，所以需要更新 SceneKit 几何体以匹配
        plane.update(anthor: anchor as! ARPlaneAnchor)
        
    }
    
    /**
     从 scene graph 中移除与给定 anchor 映射的 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 被移除的 node。
     @param anchor 被移除的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // 如果多个独立平面被发现共属某个大平面，此时会合并它们，并移除这些 node
        planes.removeValue(forKey: anchor.identifier)
    }
    
    /**
     将要用给定 anchor 的数据来更新时 node 调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 即将更新的 node。
     @param anchor 被更新的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
