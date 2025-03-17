import UIKit
import RealityKit
import ARKit

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
                // Place video on image anchor
            }
        }
    }
}
