import SwiftUI
import SceneKit

struct ContentView: View {
    var body: some View {
        SceneKitView()
            .edgesIgnoringSafeArea(.all)
    }
}

struct SceneKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .white
        
        // Create and configure the scene
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Add camera
         let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zNear = 0.01
        camera.zFar = 1000
        cameraNode.position = SCNVector3(x: 0, y: 0, z:0.8)
        cameraNode.camera = camera
         scene.rootNode.addChildNode(cameraNode)
        
        // Add box
        let boxGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red // Set the box color to red
        boxGeometry.materials = [material]
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(boxNode)
        
        // Add pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGestureQ(_:)))
        sceneView.addGestureRecognizer(panGesture)
        
        // Store the box node in the coordinator
        context.coordinator.boxNode = boxNode
        sceneView.pointOfView = cameraNode
        sceneView.isPlaying = true

        return sceneView
        
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var boxNode: SCNNode?
        
        @objc func panGestureQ(_ gestureRecognize: UIPanGestureRecognizer) {
            guard let boxNode = boxNode else { return }
            
            let translation = gestureRecognize.translation(in: gestureRecognize.view!)
            let angleY = Float(translation.x) * 0.003
            let angleX = Float(translation.y) * 0.003
            
            let rotationX = simd_quaternion(angleX, simd_float3(x: 1, y: 0, z: 0))
            let rotationY = simd_quaternion(angleY, simd_float3(x: 0, y: 1, z: 0))
            
            let combined = rotationX * rotationY
            
            let tempNode = SCNNode()
            tempNode.simdOrientation = boxNode.simdOrientation
            let zBefore = tempNode.eulerAngles.z
            
            tempNode.simdOrientation =  combined * tempNode.simdOrientation
            
            let zAfter = tempNode.eulerAngles.z
            let zDiff = zAfter - zBefore
            print("Z rotation for this was ", zDiff)
            
            let rotationZ = simd_quaternion(zDiff, simd_float3(x: 0, y: 0, z: 1))

            boxNode.simdOrientation =  combined * boxNode.simdOrientation
            
            print("Z of object after is ", boxNode.eulerAngles.z)

            
            gestureRecognize.setTranslation(CGPoint.zero, in: gestureRecognize.view)
            
           
        }
        
        @objc func panGesture(_ gestureRecognize: UIPanGestureRecognizer) {
            guard let boxNode = boxNode else { return }
            
            let scale = 0.03
            let translation = gestureRecognize.translation(in: gestureRecognize.view!)
            let xRotation = Float(translation.y) * Float.pi / 180
            let yRotation = Float(translation.x) * Float.pi / 180
            
            boxNode.eulerAngles.x += xRotation * Float(scale)
            boxNode.eulerAngles.y += yRotation * Float(scale)
            
            gestureRecognize.setTranslation(CGPoint.zero, in: gestureRecognize.view)
        }
        
       
    }
}

@main
struct RotationExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
