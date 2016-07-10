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
    /// An enum whose cases describe how a user can manipulate the camera to navigate around the video.
    enum NavigationMode
    {
        /// Navigation occurs via UIPanGestureRecognizer.
        case PanGesture
        
        /// Navigation occurs via CMDeviceMotion.
        case DeviceMotion
    }
    
    /// The radius of the sphere on which we project the video texture.
    static let SphereRadius: CGFloat = 100 // TODO: How to choose the sphere radius? [AH] 7/7/2016
    
    /// The amount of rotation in radians that can be applied by a single pan gesture.
    static let MaxPanGestureRotation: Radians = 2 * Float(M_PI) // 360 degrees

    /// The interval at which device motion updates will be reported.
    static let DeviceMotionUpdateInterval: NSTimeInterval = 1 / 60
    
    /// The video player responsible for playback of our video content.
    var player: AVPlayer!
    
    /// The camera node located at the center of our sphere whose camera property is the user's view point.
    var cameraNode: SCNNode!

    /// The mode by which the user navigates around the video sphere. Options are pan gesture and device motion.
    var navigationMode: NavigationMode = .DeviceMotion
    {
        didSet
        {
            guard oldValue != self.navigationMode else // If the value has not changed, do nothing.
            {
                return
            }
            
            switch self.navigationMode
            {
            case .PanGesture:
                self.motionManager.stopDeviceMotionUpdates()
                self.panGestureRecognizer.enabled = true
                
            case .DeviceMotion:
                self.panGestureRecognizer.enabled = false
                self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical)
            }
        }
    }
    
    /// The pan gesture used for navigation.
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// The camera node's euler angles when a pan gesture begins. These are reset to nil when a pan gesture ends.
    var initialEulerAngles: SCNVector3?
    
    /// The camera node's euler angles as adjusted by a pan gesture. They will be applied at the next renderer:updateAtTime: call. These are reset to nil when a pan gesture ends.
    var currentEulerAngles: SCNVector3?

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
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didPan(_:)))
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    private func setupDeviceMotionManager()
    {
        guard self.motionManager.deviceMotionAvailable == true else
        {
            assertionFailure("Device motion is unavailable.") // TODO: Replace this with something better. [AH] 7/7/2016
            
            return
        }
        
        self.motionManager.deviceMotionUpdateInterval = self.dynamicType.DeviceMotionUpdateInterval
        
        if self.navigationMode == .DeviceMotion
        {
            self.motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryZVertical)
        }
    }
    
    // MARK: Gestures
    
    func didPan(recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .Began:
            self.initialEulerAngles = self.cameraNode.eulerAngles
            
        case .Changed:
            guard let initialEulerAngles = self.initialEulerAngles else
            {
                assertionFailure("Attempt to unwrap initialEulerAngles failed. These should not be nil.")

                return
            }

            let translation = recognizer.translationInView(recognizer.view)

            // Use the pan translation along the x axis to adjust the camera's rotation about the y axis.
            let xScalar = Float(translation.x / self.view.bounds.size.width)
            let yRadians = xScalar * self.dynamicType.MaxPanGestureRotation
            let yCurrent = (initialEulerAngles.y + yRadians) % Float(2 * M_PI) // Mod by 360 in order to maintain 0 <= y < 360.
            
            // Use the pan translation along the y axis to adjust the camera's rotation about the x axis
            let yScalar = Float(translation.y / self.view.bounds.size.height)
            let xRadians = yScalar * self.dynamicType.MaxPanGestureRotation
            let xCurrent = (initialEulerAngles.x + xRadians) % Float(2 * M_PI) // Mod by 360 in order to maintain 0 <= x < 360.

            // Store the new values so they can be applied in renderer:updateAtTime:.
            self.currentEulerAngles = SCNVector3Make(xCurrent, yCurrent, initialEulerAngles.z)
            
        case .Ended, .Cancelled, .Failed:
            self.initialEulerAngles = nil
            self.currentEulerAngles = nil
            
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

            switch strongSelf.navigationMode
            {
            case .PanGesture:
                if let currentEulerAngles = strongSelf.currentEulerAngles // This is nil when there is no active gesture.
                {
                    strongSelf.cameraNode.eulerAngles = currentEulerAngles
                }
                
            case .DeviceMotion:
                guard strongSelf.motionManager.deviceMotionAvailable == true else
                {
                    assertionFailure("Device motion is unavailable.") // TODO: Replace this with something better. [AH] 7/7/2016
                    
                    return
                }
                
                if let motion = strongSelf.motionManager.deviceMotion // Device motion can be nil at times. This is ok.
                {
                    strongSelf.cameraNode.orientation = motion.gaze(atOrientation: UIApplication.sharedApplication().statusBarOrientation)
                }
            }
        }
    }
}
