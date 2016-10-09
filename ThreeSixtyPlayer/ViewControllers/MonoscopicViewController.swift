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
    
    private let sceneView = SCNView()

    private let player: AVPlayer

    private let scene: MonoscopicScene
    
    var video: Video?
    {
        didSet
        {
            guard let video = self.video else
            {
                self.player.pause()
                self.player.replaceCurrentItem(with: nil)
                
                return
            }
            
            switch video.type
            {
            case .monoscopic:
                self.scene.update(resolution: video.resolution)
                
            case .stereoscopic(layout: let layout):
                // In the event that we want to display a stereoscopic video as monoscopic
                // (Perhaps the user has no stereoscopic headset and we don't have a mono version of the video)
                // We arbitrarily select the left eye mapping.
                self.scene.update(resolution: video.resolution, mapping: layout.leftEyeMapping)
            }
            
            // TODO: Can we link updating scene resolution with replacing the player item?
            self.player.replaceCurrentItem(with: video.playerItem)
            self.player.play()
        }
    }

    init(player: AVPlayer)
    {
        self.player = player
        self.scene = MonoscopicScene(player: self.player)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        
        self.setupSceneView()        
        self.setupNavigator()
        self.setupConstraints()
        
        // Invoking play on the sceneView seems to allow it to begin obeying autolayout constraints / autoresizing mask.
        // Without this, sceneView doesn't resize on device rotation. 
        self.sceneView.play(nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        self.player.pause()
    }
    
    // MARK: - Setup
    
    private func setupSceneView()
    {
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

