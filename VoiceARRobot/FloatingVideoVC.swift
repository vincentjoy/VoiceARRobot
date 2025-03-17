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
                
            }
        }
    }
    
    // MARK: - Video Screen
    
    func createVideoScreen(width: Float, height: Float) -> ModelEntity {
        // Mesh
        let screenMesh = MeshResource.generatePlane(width: width, height: height)
        
        // Video material
        let videoItem = createVideoItem(with: "ElonClip")
        let videoMaterial = createVideoMaterial(with: videoItem!)
        
        // Model entity
        let videoScreenEntity = ModelEntity(mesh: screenMesh, materials: [videoMaterial])
        
        return videoScreenEntity
    }
    
    func createVideoItem(with fileName: String) -> AVPlayerItem? {
        // URL
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ".mp4") else {
            return nil
        }
        
        // Video item
        let asset = AVURLAsset(url: url)
        let videoItem = AVPlayerItem(asset: asset)
        
        return videoItem
    }
    
    func createVideoMaterial(with videoItem: AVPlayerItem) -> VideoMaterial {
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
