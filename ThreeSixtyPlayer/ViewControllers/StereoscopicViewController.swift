//
//  StereoscopicViewController.swift
//  ThreeSixtyPlayer
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
import AVFoundation

class StereoscopicViewController: UIViewController, SCNSceneRendererDelegate
{
    /// The navigator that manages a pan gesture and device motion.
    private let navigator = ThreeSixtyNavigator()

    private var scene: StereoscopicScene!
    
    private var leftSceneView: SCNView!
    private var rightSceneView: SCNView!
    
    /// The video player.
    var player: AVPlayer! // TODO: Move into init
    
    /// An enum case that describes the video type, resolution, and layout (in the case of stereoscopic).
    var video: SphericalVideo! // TODO: Make optional or move into init
        
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard case VideoType.stereoscopic(layout: let layout) = self.video.type else
        {
            fatalError("Attempt to load non-stereo video in stereo view controller.")
        }
        
        self.view.backgroundColor = UIColor.black

        let configuration = StereoscopicSceneConfiguration(resolution: self.video.resolution, layout: layout)
        self.scene = StereoscopicScene(player: self.player, initialConfiguration: configuration)

        self.setupSceneViews()
        self.setupNavigator()
        self.setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.startPlayback()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.stopPlayback()
    }
    
    // MARK: Setup
    
    private func setupSceneViews()
    {
        self.leftSceneView = self.makeSceneView(withScene: self.scene, cameraNode: self.scene.leftCameraNode)
        self.rightSceneView = self.makeSceneView(withScene: self.scene, cameraNode: self.scene.rightCameraNode)
    
        self.view.addSubview(self.leftSceneView)
        self.view.addSubview(self.rightSceneView)
    }
    
    private func makeSceneView(withScene scene: StereoscopicScene, cameraNode: SCNNode) -> SCNView
    {
        let sceneView = SCNView()
        sceneView.showsStatistics = true
        sceneView.backgroundColor = UIColor.black
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.delegate = self
        sceneView.scene = scene
        sceneView.pointOfView = cameraNode
        
        return sceneView
    }

    private func setupNavigator()
    {
        // Ensure that navigator's pan gesture is added to our view.
        self.navigator.setupPanGestureRecognizer(withView: self.view)
        
        // Navigation mode is initially .None.
        self.navigator.navigationMode = .panGestureAndDeviceMotion
    }
    
    // MARK: Constraints 
    
    private func setupConstraints()
    {
        let leftTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.leftSceneView, attribute: .top, multiplier: 1, constant: 0)
        let leftLeadingConstraint = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.leftSceneView, attribute: .leading, multiplier: 1, constant: 0)
        let leftBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.leftSceneView, attribute: .bottom, multiplier: 1, constant: 0)
        
        let middleConstraint = NSLayoutConstraint(item: self.leftSceneView, attribute: .trailing, relatedBy: .equal, toItem: self.rightSceneView, attribute: .leading, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: self.leftSceneView, attribute: .width, relatedBy: .equal, toItem: self.rightSceneView, attribute: .width, multiplier: 1, constant: 0)
        
        let rightTopConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.rightSceneView, attribute: .top, multiplier: 1, constant: 0)
        let rightTrailingConstraint = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.rightSceneView, attribute: .trailing, multiplier: 1, constant: 0)
        let rightBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.rightSceneView, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.view.addConstraint(leftTopConstraint)
        self.view.addConstraint(leftLeadingConstraint)
        self.view.addConstraint(leftBottomConstraint)
        self.view.addConstraint(middleConstraint)
        self.view.addConstraint(widthConstraint)
        self.view.addConstraint(rightTopConstraint)
        self.view.addConstraint(rightTrailingConstraint)
        self.view.addConstraint(rightBottomConstraint)
    }
    
    // MARK: Playback
    
    private func startPlayback()
    {
        self.leftSceneView.play(nil)
        self.rightSceneView.play(nil)
        self.player.play()
    }

    private func stopPlayback()
    {
        self.leftSceneView.stop(nil)
        self.rightSceneView.stop(nil)
        self.player.pause()
    }

    // MARK: SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        // TODO: Necessary to dispatch to main? Implications of doing so? Thread safty of navigator class / pan recognizer is one issue.
        
        DispatchQueue.main.async { [weak self] () -> Void in
            guard let strongSelf = self else
            {
                return
            }

            let orientation = strongSelf.navigator.updateCurrentOrientation()
            
            strongSelf.scene.leftCameraNode.orientation = orientation
            strongSelf.scene.rightCameraNode.orientation = orientation
        }
    }
}

