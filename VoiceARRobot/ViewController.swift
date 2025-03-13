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
    
    private var robotEntity: Entity?
    private var objectAnchor: AnchorEntity?
    private var moveToLocation: Transform?
    private var movementDuration: Double = 5 // seconds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start and initialize
        startARSession()
        
        // Load 3D Models
        robotEntity = try! Entity.load(named: "robot")
        
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
            
            // Start Moving
            move(direction: .forward)
        }
    }
    
    private func placeObject(object modelEntity: Entity, at position: SIMD3<Float>) {
        
        // 1. Create anchor (at a 3D position)
        objectAnchor = AnchorEntity(world: position)
        
        // 2. Tie model to anchor
        objectAnchor!.addChild(modelEntity)
        
        // 3. Add anchor to scene
        arView.scene.addAnchor(objectAnchor!)
    }
    
    private func move(direction: Directions) {
        switch direction {
        case .forward:
            // Move
            moveToLocation?.translation = robotEntity!.transform.translation + simd_float3(x:0, y:0, z: 20) // Take the robot's current location and move it to 20 centimeters, to move forward
            robotEntity?.move(to: moveToLocation!, relativeTo: robotEntity, duration: movementDuration)
            
            // Animation
            walkAnimation(movementDuration)
        case .back:
            // Move
            moveToLocation?.translation = robotEntity!.transform.translation + simd_float3(x:0, y:0, z: -20) // Take the robot's current location and move it to -20 centimeters, to move backward
            robotEntity?.move(to: moveToLocation!, relativeTo: robotEntity, duration: movementDuration)
            
            // Animation
            walkAnimation(movementDuration)
        case .left:
            let rotateToAngle = simd_quatf(angle: GLKMathDegreesToRadians(90), axis: SIMD3(x: 0, y: 1, z: 0))
            robotEntity?.setOrientation(rotateToAngle, relativeTo: robotEntity)
        case .right:
            let rotateToAngle = simd_quatf(angle: GLKMathDegreesToRadians(-90), axis: SIMD3(x: 0, y: 1, z: 0))
            robotEntity?.setOrientation(rotateToAngle, relativeTo: robotEntity)
        }
    }
    
    private func walkAnimation(_ movementDuration: Double) {
        // USDZ Animation
        if let robotAnimation = robotEntity?.availableAnimations.first {
            // Play the animation
            robotEntity?.playAnimation(robotAnimation.repeat(duration: movementDuration), transitionDuration: 0.5, startsPaused: false)
        } else {
            print("No animation present in the USDZ file")
        }
    }
}

enum Directions: String {
    case forward, back, left, right
}
