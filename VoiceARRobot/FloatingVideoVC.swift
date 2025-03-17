import UIKit
import RealityKit
import ARKit
import AVKit

class FloatingVideoVC: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Starting image tracking
        startImageTracking()
        
        arView.session.delegate = self
    }
    
    private func startImageTracking() {
        
        // Images to track
        guard let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Pics", bundle: Bundle.main) else { return }
        
        // Configure image tracking
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = imageToTrack
        configuration.maximumNumberOfTrackedImages = 1
        
        // Start session
        arView.session.run(configuration)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let imageAnchor = anchor as? ARImageAnchor {
                // Create video screen
                let width = Float(imageAnchor.referenceImage.physicalSize.width)
                let height = Float(imageAnchor.referenceImage.physicalSize.height)
                let videoScreen = createVideoScreen(width: width,
                                                    height: height)
                
                // Place that screen on to image anchor
                placeVideoScreen(videoEntity: videoScreen, imageAnchor: imageAnchor)
            }
        }
    }
    
    // MARK: - Object placement
    private func placeVideoScreen(videoEntity: ModelEntity, imageAnchor: ARImageAnchor) {
        // Anchor entity
        let imageAnchorEntity = AnchorEntity(anchor: imageAnchor)
        
        // Rotate 90 degrees in X axis
        let rotationAngle = simd_quatf(angle: GLKMathDegreesToRadians(-90), axis: SIMD3(x: 1, y: 0, z: 0))
        videoEntity.setOrientation(rotationAngle, relativeTo: imageAnchorEntity)
        
        // Postion the video screen to the side of the image
        let bookWidth = Float(imageAnchor.referenceImage.physicalSize.width)
        videoEntity.setPosition(SIMD3(x: bookWidth, y: 0, z: 0), relativeTo: imageAnchorEntity)
        
        // Attach model to anchor
        imageAnchorEntity.addChild(videoEntity)
        
        // Add anchor to scene
        arView.scene.addAnchor(imageAnchorEntity)
    }
    
    // MARK: - Video Screen
    
    private func createVideoScreen(width: Float, height: Float) -> ModelEntity {
        // Mesh
        let screenMesh = MeshResource.generatePlane(width: width, height: height)
        
        // Video material
        let videoItem = createVideoItem(with: "ElonClip")
        let videoMaterial = createVideoMaterial(with: videoItem!)
        
        // Model entity
        let videoScreenEntity = ModelEntity(mesh: screenMesh, materials: [videoMaterial])
        
        return videoScreenEntity
    }
    
    private func createVideoItem(with fileName: String) -> AVPlayerItem? {
        // URL
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ".mp4") else {
            return nil
        }
        
        // Video item
        let asset = AVURLAsset(url: url)
        let videoItem = AVPlayerItem(asset: asset)
        
        return videoItem
    }
    
    private func createVideoMaterial(with videoItem: AVPlayerItem) -> VideoMaterial {
        // Video player
        let player = AVPlayer()
        
        // Video material
        let videoMaterial = VideoMaterial(avPlayer: player)
        
        // Play video
        player.replaceCurrentItem(with: videoItem)
        player.play()
        
        return videoMaterial
    }
}
