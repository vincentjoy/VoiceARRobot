//
//  ViewController.swift
//  VoiceARRobot
//
//  Created by Vincent Joy on 12/03/25.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var arView: ARView!
    private var robotEntity: ModelEntity?
    private var objectAnchor: AnchorEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start and initialize
        startARSession()
        
        // Load 3D Models
        robotEntity = try! Entity.loadModel(named: "robot")
        
        // Tap detector
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    private func startARSession() {
        
        arView.automaticallyConfigureSession = true
        
        // Plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.debugOptions = .showAnchorGeometry
        arView.session.run(configuration)
    }
    
    @objc
    private func handleTap(recognizer: UITapGestureRecognizer) {
        
        // Touch location
        let tapLocation = recognizer.location(in: arView)
        
        // Raycast (2D -> 3D pos)
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        // If plane detected
        if let firstResult = results.first {
            
            // 3D pos (x, y, z)
            let worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            
            // Place that 3D model at the plane
            placeObject(object: robotEntity!, at: worldPosition)
        }
    }
    
    private func placeObject(object modelEntity: ModelEntity, at position: SIMD3<Float>) {
        
        // 1. Create anchor (at a 3D position)
        objectAnchor = AnchorEntity(world: position)
        
        // 2. Tie model to anchor
        objectAnchor!.addChild(modelEntity)
        
        // 3. Add anchor to scene
        arView.scene.addAnchor(objectAnchor!)
    }
}
