//
//  ViewController.swift
//  360Player
//
//  Created by Alfred Hanssen on 7/5/16.
//  Copyright © 2016 Alfie Hanssen. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import SceneKit
import SpriteKit
import AVFoundation
import CoreMotion

class ViewController: UIViewController, SCNSceneRendererDelegate
{
    enum NavigationMode
    {
        case PanGesture
        case DeviceMotion
    }
    
    ///
    var currentOrientation: GLKQuaternion?
    
    /// The radius of the sphere on which we project the video texture.
    static let SphereRadius: CGFloat = 100 // TODO: How to choose the sphere radius? [AH] 7/7/2016
    
    /// The amount of rotation in degrees that can be applied by a single pan gesture.
    static let MaxPanGestureRotation: Degrees = 360

    /// The interval at which device motion updates will be reported.
    static let DeviceMotionUpdateInterval: NSTimeInterval = 1 / 60
    
    /// The video player responsible for playback of our video content.
    var player: AVPlayer!
    
    /// The camera node located at the center of our sphere whose camera property is the user's view point.
    var cameraNode: SCNNode!

    /// The motion manager used to adjust camera position based on device motion.
    let motionManager = CMMotionManager()
    
    // MARK: Life Cycle
    
    deinit
    {
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupScene()
        self.setupPanGestureRecognizer()
        self.setupDeviceMotionManager()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        guard let sceneView = self.view as? SCNView else
        {
            assertionFailure("Attempt to cast self.view as SCNView failed.")
            
            return
        }

        sceneView.playing = true
        self.player.play()
    }

    // MARK: Setup
    
    private func setupScene()
    {
        guard let sceneView = self.view as? SCNView else
        {
            assertionFailure("Attempt to cast self.view as SCNView failed.")
            
            return
        }
     
        // Scene
        let scene = SCNScene()

        // Scene view
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.lightGrayColor()
        sceneView.delegate = self
        
        // Video resource
        guard let path = NSBundle.mainBundle().pathForResource("balloons", ofType: "mp4")
            where NSFileManager.defaultManager().fileExistsAtPath(path) else
        {
            assertionFailure("Unable to construct path to video resource.")
            
            return
        }
        
        let url = NSURL.fileURLWithPath(path)
        let urlAsset = AVURLAsset(URL: url)
        guard let size = urlAsset.encodedResolution() else // TODO: Does this capture screen scale? [AH] 7/7/2016
        {
            assertionFailure("Unable to access encoded resolution for video resource.")
            
            return
        }

        self.player = AVPlayer(URL: url)

        // Video node
        let videoNode = SKVideoNode(AVPlayer: self.player)
        videoNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        videoNode.size = size
        videoNode.yScale = -1 // Flip the video so it appears right side up
        
        // SKScene
        let skScene = SKScene(size: size)
        skScene.scaleMode = .AspectFit
        skScene.addChild(videoNode)

        // Material
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        material.cullMode = .Front // Ensure that the material renders on the inside of our sphere

        // Sphere geometry
        let sphere = SCNSphere(radius: self.dynamicType.SphereRadius)
        sphere.firstMaterial = material

        // Geometry node
        let geometryNode = SCNNode(geometry: sphere)
        geometryNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(geometryNode)

        // Camera
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true

        // Camera node
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode
    }
    
    private func setupPanGestureRecognizer()
    {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didPan(_:)))
        self.view.addGestureRecognizer(recognizer)
    }
    
    private func setupDeviceMotionManager()
    {
        guard self.motionManager.deviceMotionAvailable == true else
        {
            assertionFailure("Device motion is unavailable.") // TODO: Replace this with something better. [AH] 7/7/2016
            
            return
        }
        
        self.motionManager.deviceMotionUpdateInterval = self.dynamicType.DeviceMotionUpdateInterval
        self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical)
    }
    
    // MARK: Gestures
    
    func didPan(recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .Began, .Changed:
            let translation = recognizer.translationInView(recognizer.view)

            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis
            let xScalar = Float(translation.x / self.view.bounds.size.width)
            let yDegrees = xScalar * self.dynamicType.MaxPanGestureRotation
            let yRadians = yDegrees.toRadians()
            let yQuaternion = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
            
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis
            let yScalar = Float(translation.y / self.view.bounds.size.height)
            let xDegrees = yScalar * self.dynamicType.MaxPanGestureRotation
            let xRadians = xDegrees.toRadians()
            let xQuaternion = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
            
            self.currentOrientation = GLKQuaternionMultiply(yQuaternion, xQuaternion)
            
        case .Ended, .Cancelled, .Failed:
            break
            
        case .Possible:
            break
        }
    }
    
    // MARK: SCNSceneRendererDelegate
    
    func renderer(renderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval)
    {
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            
            guard let strongSelf = self else
            {
                return
            }
            
            // TODO: Does this need to be wrapped in a transaction? [AH] 7/8/2016
            
            guard strongSelf.motionManager.deviceMotionAvailable == true else
            {
                assertionFailure("Device motion is unavailable.") // TODO: Replace this with something better. [AH] 7/7/2016

                return
            }
            
            guard let motion = strongSelf.motionManager.deviceMotion else // Device motion can be nil at times. This is ok. 
            {
                return
            }
            
            if let currentOrientation = strongSelf.currentOrientation
            {
//                let scnQuaternion = motion.gaze(atOrientation: UIApplication.sharedApplication().statusBarOrientation)
//                let glkQuaternion = GLKQuaternionMake(scnQuaternion.x, scnQuaternion.y, scnQuaternion.z, scnQuaternion.w)
//                var glkResult = GLKQuaternionMultiply(currentOrientation, glkQuaternion)
                
//                let scnOrientation = SCNQuaternion(x: glkResult.x, y: glkResult.y, z: glkResult.z, w: glkResult.w)
//                strongSelf.cameraNode.orientation = scnOrientation

//                let glkQuaternion = GLKQuaternionMake(scnQuaternion.x, scnQuaternion.y, scnQuaternion.z, scnQuaternion.w)
//                var glkResult = GLKQuaternionMultiply(currentOrientation, cameraOrientation)
//                let scnOrientation = SCNQuaternion(x: currentOrientation.x, y: currentOrientation.y, z: currentOrientation.z, w: currentOrientation.w)
//                strongSelf.cameraNode.orientation = scnOrientation

            }
            else
            {
                strongSelf.cameraNode.orientation = motion.gaze(atOrientation: UIApplication.sharedApplication().statusBarOrientation)
            }
        }
    }
}
