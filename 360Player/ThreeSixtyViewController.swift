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

class ThreeSixtyViewController: UIViewController, SCNSceneRendererDelegate
{
    /// An enum whose cases describe how a user can manipulate the camera to navigate around the video.
    enum NavigationMode
    {
        /// Navigation occurs via UIPanGestureRecognizer.
        case panGesture
        
        /// Navigation occurs via CMDeviceMotion.
        case deviceMotion
        
        // TODO: Add case for .PanGestureAndDeviceMotion.
    }
    
    /// The amount of rotation in radians that can be applied by a single pan gesture.
    fileprivate static let MaxPanGestureRotation: Float = GLKMathDegreesToRadians(360)

    /// The interval at which device motion updates will be reported.
    fileprivate static let DeviceMotionUpdateInterval: TimeInterval = 1 / 60
    
    /// The pan gesture recognizer used for navigation.
    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    
    /// The translation value previously reported via the UIPanGestureRecognizerDelegate.
    fileprivate var previousPanTranslation: CGPoint?

    /// The translation delta between the previously and currently reported translations.
    fileprivate var panTranslationDelta: CGPoint?

    /// The motion manager used to adjust camera position based on device motion.
    fileprivate let motionManager = CMMotionManager()

    /// The video player that renders onto the scene sphere.
    fileprivate let player: AVPlayer

    /// The scene that contains the sphere geometry.
    fileprivate let scene: ThreeSixtyScene
    
    /// The mode by which the user navigates around the video sphere. Options are pan gesture, device motion, and both.
    var navigationMode: NavigationMode = .deviceMotion // TODO: Change default value to both.
    {
        didSet
        {
            guard oldValue != self.navigationMode else // If the value has not changed, do nothing.
            {
                return
            }
            
            switch self.navigationMode
            {
            case .panGesture:
                self.motionManager.stopDeviceMotionUpdates()
                self.panGestureRecognizer.isEnabled = true
                
            case .deviceMotion:
                self.panGestureRecognizer.isEnabled = false
                self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
            }
        }
    }

    // MARK: Life Cycle
    
    deinit
    {
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    required init(player: AVPlayer, videoSize: CGSize) // TODO: Do not pass in size, observe changes to currentItem?
    {
        self.player = player

        self.scene = ThreeSixtyScene(player: player, videoSize: videoSize)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView()
    {
        let sceneView = SCNView()
        sceneView.scene = self.scene
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.delegate = self
        sceneView.pointOfView = self.scene.cameraNode

        self.view = sceneView
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupPanGestureRecognizer()
        self.setupDeviceMotionManager()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        guard let sceneView = self.view as? SCNView else
        {
            assertionFailure("Attempt to cast self.view as SCNView failed.")
            
            return
        }

        // TODO: link these two calls somehow.
        sceneView.play(nil)
        self.scene.player.play()
    }
    
    // MARK: Setup
    
    fileprivate func setupPanGestureRecognizer()
    {
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(type(of: self).didPan(_:)))
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    fileprivate func setupDeviceMotionManager()
    {
        guard self.motionManager.isDeviceMotionAvailable == true else
        {            
            return
        }
        
        self.motionManager.deviceMotionUpdateInterval = type(of: self).DeviceMotionUpdateInterval
        
        if self.navigationMode == .deviceMotion
        {
            self.motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical)
        }
    }
    
    // MARK: Gestures
    
    func didPan(_ recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .began:
            self.previousPanTranslation = .zero
            
        case .changed:
            guard let previous = self.previousPanTranslation else
            {
                assertionFailure("Attempt to unwrap previous pan translation failed.")
                
                return
            }

            // Calculate how much translation occurred between this step and the previous step
            let translation = recognizer.translation(in: recognizer.view)
            
            // Save the translation and translation delta for later use
            self.panTranslationDelta = CGPoint(x: translation.x - previous.x, y: translation.y - previous.y)
            self.previousPanTranslation = translation
            
        case .ended, .cancelled, .failed:
            // Reset saved values for use in future pan gestures
            self.previousPanTranslation = nil
            self.panTranslationDelta = nil
            
        case .possible:
            break
        }
    }
    
    // MARK: SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        DispatchQueue.main.async { [weak self] () -> Void in
            
            guard let strongSelf = self else
            {
                return
            }

            // TODO: Does this need to be wrapped in a transaction? [AH] 7/8/2016

            switch strongSelf.navigationMode
            {
            case .panGesture:
                guard let translationDelta = self?.panTranslationDelta else
                {                    
                    return
                }
                
                // Use the pan translation along the x axis to adjust the camera's rotation about the y axis.
                let yScalar = Float(translationDelta.x / strongSelf.view.bounds.size.width)
                let yRadians = yScalar * type(of: strongSelf).MaxPanGestureRotation
                
                // Use the pan translation along the y axis to adjust the camera's rotation about the x axis.
                let xScalar = Float(translationDelta.y / strongSelf.view.bounds.size.height)
                let xRadians = xScalar * type(of: strongSelf).MaxPanGestureRotation

                strongSelf.scene.cameraNode.eulerAngles.x += xRadians
                strongSelf.scene.cameraNode.eulerAngles.y += yRadians
                
//                let xMatrix = SCNMatrix4MakeRotation(xRadians, 1, 0, 0)
//                let yMatrix = SCNMatrix4MakeRotation(yRadians, 0, 1, 0)
//                let rotation = SCNMatrix4Mult(yMatrix, xMatrix)
//                strongSelf.scene.cameraNode.transform = SCNMatrix4Mult(rotation, strongSelf.scene.cameraNode.transform)
                
                
//                var transform = strongSelf.cameraNode.transform
//                transform = SCNMatrix4Rotate(transform, xRadians, 1, 0, 0)
//                transform = SCNMatrix4Rotate(transform, yRadians, 0, 1, 0)
//                strongSelf.cameraNode.transform = transform

//                transform = SCNMatrix4Mult(xMatrix, transform)
//                strongSelf.cameraNode.transform = transform
//
//                let test = strongSelf.scene.rootNode.convertTransform(yMatrix, toNode: strongSelf.cameraNode)
//
//                transform = strongSelf.cameraNode.transform
//                transform = SCNMatrix4Mult(test, transform)
//                strongSelf.cameraNode.transform = transform

                
//                // Use the radian values to construct quaternions
//                let x = GLKQuaternionMakeWithAngleAndAxis(xRadians, 1, 0, 0)
//                let y = GLKQuaternionMakeWithAngleAndAxis(yRadians, 0, 1, 0)
//                let combination = GLKQuaternionMultiply(y, x)
//
//                // Multiply the quaternions to obtain an updated orientation
//                let scnOrientation = strongSelf.cameraNode.orientation
//                let glkOrientation = GLKQuaternionMake(scnOrientation.x, scnOrientation.y, scnOrientation.z, scnOrientation.w)
//                let q = GLKQuaternionMultiply(x, glkOrientation)
//
//                // And finally set the current orientation to the updated orientation
//                strongSelf.cameraNode.orientation = SCNQuaternion(x: q.x, y: q.y, z: q.z, w: q.w)

            case .deviceMotion:
                guard strongSelf.motionManager.isDeviceMotionAvailable == true else
                {
                    assertionFailure("Device motion is unavailable.") // TODO: Replace this with something better. [AH] 7/7/2016
                    
                    return
                }
                
                if let motion = strongSelf.motionManager.deviceMotion // Device motion can be nil at times. This is ok.
                {
                    strongSelf.scene.cameraNode.orientation = motion.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
                }
            }
        }
    }
}

