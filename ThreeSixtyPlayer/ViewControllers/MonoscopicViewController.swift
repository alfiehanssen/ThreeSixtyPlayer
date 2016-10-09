//
//  MonoscopicViewController.swift
//  ThreeSixtyPlayer
//
//  Created by Alfred Hanssen on 10/6/16.
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

class MonoscopicViewController: UIViewController, SCNSceneRendererDelegate
{
    /// The navigator that manages a pan gesture and device motion.
    private let navigator = ThreeSixtyNavigator()
    
    private var scene: MonoscopicScene!
    
    private var sceneView: SCNView!
    
    /// The video player.
    var player: AVPlayer! // TODO: Move this into init?
    
    /// An enum case that describes the video type, resolution, and layout (in the case of stereoscopic).
    var video: Video! // TODO: Make this optional or move into init

    // MARK: - View Lifecycle 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        guard case VideoType.monoscopic = self.video.type else
        {
            fatalError("Attempt to load non-mono video in mono view controller.")
        }
        
        self.view.backgroundColor = UIColor.black
        
        self.scene = MonoscopicScene(player: self.player, resolution: self.video.resolution)
        
        self.setupSceneView()        
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
    
    // MARK: - Setup
    
    private func setupSceneView()
    {
        self.sceneView = SCNView()
        self.sceneView.showsStatistics = true
        self.sceneView.backgroundColor = UIColor.black
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.sceneView.delegate = self
        self.sceneView.scene = self.scene
        self.sceneView.pointOfView = self.scene.eye.cameraNode
        
        self.view.addSubview(self.sceneView)
    }
    
    private func setupNavigator()
    {
        // Ensure that navigator's pan gesture is added to our view.
        self.navigator.setupPanGestureRecognizer(withView: self.view)
        
        // Navigation mode is initially .None.
        self.navigator.navigationMode = .panGestureAndDeviceMotion
    }

    private func setupConstraints()
    {
        let topConstraint = NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: self.sceneView, attribute: .top, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.sceneView, attribute: .leading, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.sceneView, attribute: .bottom, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.sceneView, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.view.addConstraint(topConstraint)
        self.view.addConstraint(leadingConstraint)
        self.view.addConstraint(bottomConstraint)
        self.view.addConstraint(trailingConstraint)
    }

    // MARK: - Playback
    
    private func startPlayback()
    {
        self.sceneView.play(nil)
        self.player.play()
    }
    
    private func stopPlayback()
    {
        self.sceneView.stop(nil)
        self.player.pause()
    }
    
    // MARK: - SCNSceneRendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        // TODO: Necessary to dispatch to main? Implications of doing so? Thread safty of navigator class / pan recognizer is one issue.
        
        DispatchQueue.main.async { [weak self] () -> Void in
            guard let strongSelf = self else
            {
                return
            }
            
            let orientation = strongSelf.navigator.updateCurrentOrientation()
            
            strongSelf.scene.eye.cameraNode.orientation = orientation
        }
    }

}
