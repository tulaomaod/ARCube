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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // UUID 表示UUID字符串，可用于唯一标识类型，接口和其他项目。
    /// 字典，存储场景中当前渲染的所有平面
    var planes = [UUID : Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
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
        let plane = Plane(withAnthor: anchor)
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
        
    }
    
    /**
     从 scene graph 中移除与给定 anchor 映射的 node 时调用。
     
     @param renderer 将会用于渲染 scene 的 renderer。
     @param node 被移除的 node。
     @param anchor 被移除的 anchor。
     */
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
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
